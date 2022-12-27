class AdjudicationService
  def initialize(orders)
    # TODO: validate that orders are valid type based on turn type
    @orders = orders
    @positions = @orders.map(&:position)
    @support_hash = @orders.select(&:support?).group_by do |support_order|
      @orders.select(&:move?).find { |move_order| (support_order.area_from == move_order.position.area) && (support_order.area_to == move_order.area_to) }
    end
  end

  def adjudicate
    self.fail_invalid_orders

    # create dependency graphs based on move orders
    self.construct_incidence_matrix
    graphs = self.parse_disconnected_graphs
    cyclic_dependencies = graphs.select { |graph| self.cyclic_graph?(graph) }

    # loop through unresolved orders until a loop fails to resolve any additional orders
    previous_unresolved_order_count = @orders.select(&:unresolved?).length
    post_unresolved_order_count = nil
    while (@orders.any?(&:unresolved?) && (previous_unresolved_order_count != post_unresolved_order_count)) do
      previous_unresolved_order_count = @orders.select(&:unresolved?).length
      @orders.select(&:unresolved?).each do |order|
        self.resolve_order(order)
      end
      post_unresolved_order_count = @orders.select(&:unresolved?).length
    end

    # deal with cylical dependencies for unresolved orders
    if @orders.any?(&:unresolved?) && cyclic_dependencies.present?
      cyclic_dependencies.each do |graph|
        move_orders = @orders.select { |o| o.move? && graph.include?(o.area_to_id) }

        if move_orders.select(&:unresolved?).any?
          # if any move order is conclusively a bounce, cyclic move fails, otherwise it succeeds
          if move_orders.any? { |move_order| self.check_bounce(move_order) }
            move_orders.each { |move_order| move_order.resolution = Order::FAILED }
          else
            move_orders.each { |move_order| move_order.resolution = Order::SUCCEEDED }
          end
        end
      end
    end

    # if any orders represent supporting a move that dislodges its own unit, retry adjudication with that order failing
    invalid_orders = @orders.select { |o| self.dislodges_own_unit?(o) }
    if invalid_orders.present?
      @orders.each { |o| o.resolution = nil }
      invalid_orders.each { |o| o.resolution = Order::FAILED }
      self.adjudicate
    end

    raise 'Adjudication did not converge' if @orders.any?(&:unresolved?)
  end

  # update resolution to failed for all orders that can be proven invalid prior to formal adjudication
  def fail_invalid_orders
    # if there is no corresponding move order for a convoy or support, mark it failed
    @orders.select { |o| o.support? || o.convoy? }.each do |order|
      corresponding_order = @orders.without(order).find do |corresponding_order|
        if order.support? && (order.area_from == order.area_to)
          # if supporting a hold, make sure there is a corresponding hold/support/convoy order
          (corresponding_order.hold? || corresponding_order.support? || corresponding_order.convoy?) && (corresponding_order.position.area == order.area_to)
        else
          # TODO: ensure convoy has other requisite convoys
          (corresponding_order.position.area == order.area_from) &&
            (corresponding_order.area_to == order.area_to) &&
            (order.support? ? PathService.supportable_areas(order.position).include?(order.area_to) : true)
        end
      end
      order.resolution = Order::FAILED if corresponding_order.nil?
    end

    # if a move that requires a convoy does not have the required convoys, mark it failed
    @orders.select { |order| order.move? && PathService.requires_convoy?(order.position.area, order.area_to) }.each do |order|
      valid_paths = PathService.possible_paths(order.position, @positions.without(order.position)).select do |path|
        (path.first == order.position.area) && (path.last == order.area_to)
      end.select do |path|
        convoy_areas = path.slice(1, path.length - 2)
        convoy_areas.all? do |convoy_area|
          convoy_order = @orders.select(&:convoy?).find { |convoy_order| convoy_order.position.area == convoy_area }
          convoy_order.present? && (convoy_order.area_from == order.position.area) && (convoy_order.area_to == order.area_to)
        end
      end
      order.resolution = Order::FAILED if valid_paths.empty?
    end

    # can't convoy or move a unit to the same location
    @orders.select { |order| (order.convoy? || order.move?) && (order.area_from == order.area_to) }.each do |order|
      order.resolution = Order::FAILED
    end

    # can't convoy from land
    @orders.select { |order| order.convoy? && (order.position.area.area_type != Area::SEA) }.each do |order|
      order.resolution = Order::FAILED
    end
  end

  def resolve_order(order)
    order.resolution = case order.order_type
    when Order::MOVE
      self.resolve_move(order)
    when Order::SUPPORT
      self.resolve_support(order)
    when Order::CONVOY
      self.resolve_convoy(order)
    when Order::HOLD
      self.resolve_hold(order)
    else
      raise "Unsupported order type: #{order.order_type}"
    end
  end

  def resolve_move(order)
    # order fails if there is no valid path to its destination
    return Order::FAILED unless PathService.valid_destination?(order, @positions)

    # move fails if it requires a convoy and all convoy paths include a failed convoy
    if PathService.requires_convoy?(order.position.area, order.area_to)
      applicable_paths = PathService.possible_paths(order.position, @positions.without(order.position)).select do |path|
        (path.first == order.area_from) && (path.last == order.area_to)
      end
      possible_paths = applicable_paths.reject do |path|
        convoy_areas = path.slice(1, path.length - 2)
        @orders.any? { |o| convoy_areas.include?(o.position.area) && o.failed? }
      end
      return Order::FAILED if possible_paths.empty?
    end

    attack_hash = self.generate_attack_hash(order.area_to)
    sorted_attack_strengths = attack_hash.keys.sort_by { |strength| strength.last }.reverse
    max_attack_strength = sorted_attack_strengths.first.last
    conclusively_max_strength_orders = attack_hash.select do |strength_array|
      strength_array.first == max_attack_strength
    end.values.flatten

    order_attack_strength = attack_hash.keys.find { |strength_array| attack_hash[strength_array].include?(order) }
    max_order_attack_strength = order_attack_strength.last

    target_originating_order = @orders.find { |o| o.position.area == order.area_to }
    target_nationality = target_originating_order&.position&.player&.nationality

    target_resist_strength = if target_originating_order.present?
      if [Order::HOLD, Order::CONVOY, Order::SUPPORT].include?(target_originating_order.order_type)
        self.hold_strength(target_originating_order)
      elsif (target_originating_order.area_to == order.position.area) && !PathService.requires_convoy?(order.position.area, order.area_to)
        # head-to-head moves compete on attack strength
        self.attack_strength(target_originating_order)
      else
        if target_originating_order.succeeded?
          [0, 0]
        elsif target_originating_order.failed?
          [1, 1]
        else
          # if move order from target area is unresolved, wait until it gets resolved
          nil
        end
      end
    else
      [0, 0]
    end

    # order fails if its max strength is less than another order's minimum strength
    return Order::FAILED if sorted_attack_strengths.any? { |strength_array| max_order_attack_strength < strength_array.first }

    # check for bounce
    if (conclusively_max_strength_orders.length > 1) && conclusively_max_strength_orders.include?(order)
      competing_orders = conclusively_max_strength_orders.without(order)
      # remove any competing orders that are dislodged as they do not factor into bounces
      competing_orders.reject! do |competing_order|
        @orders.select(&:move?).select(&:succeeded?).any? { |potentially_dislodging_order| potentially_dislodging_order.area_to == competing_order.position.area }
      end
      # if all other competing orders failed, then subject order succeeds
      return Order::SUCCEEDED if competing_orders.empty?

      # fails due to bounce if other competing orders
      return Order::FAILED if (competing_orders.any? && competing_orders.all? { |co| co.failed? || self.dependencies_resolved?(co) })
    end

    if target_resist_strength.present?
      # order fails if its maximum strength is less than or equal to minimum target hold strength
      return Order::FAILED if (max_order_attack_strength <= target_resist_strength.first)

      all_support_resolved = attack_hash.values.flatten.all? { |move_order| @support_hash[move_order].nil? || @support_hash[move_order].all?(&:resolved?) }

      if all_support_resolved && (conclusively_max_strength_orders.length == 1) && (conclusively_max_strength_orders.first == order) && (max_attack_strength > target_resist_strength.last)
        # when not targeting area occupied by own unit
        if (target_nationality != order.position.player.nationality)
          adjusted_attack_strength = max_attack_strength

          return (adjusted_attack_strength > target_resist_strength.last) ? Order::SUCCEEDED : Order::FAILED
        end

        # when targeting an area occupied by your own unit
        if target_originating_order.present? && (target_nationality == order.position.player.nationality)
          # order fails if the target is of the same nationality and unit is not exiting position
          if (!target_originating_order.move? || (target_originating_order.move? && target_originating_order.failed?))
            return Order::FAILED
          elsif (target_originating_order.move? && target_originating_order.succeeded?)
            return Order::SUCCEEDED
          end
        end
      end
    end

    nil
  end

  def resolve_support(order)
    potential_cutting_orders = @orders.select(&:move?).select do |move_order|
      move_order.area_to == order.position.area
    end

    # support order is unresolved if any potential cutting orders require a convoy but are unresolved
    return nil if potential_cutting_orders.any? { |cutting_order| cutting_order.unresolved? && PathService.requires_convoy?(cutting_order.position.area, cutting_order.area_to) }

    # cutting order does not succeed if it requires a convoy which failed
    #   or if the cutting order originates from where support is attacking
    #   or if cutting order is the same nationality as the support
    cutting_orders = potential_cutting_orders.reject do |cutting_order|
      (cutting_order.failed? && PathService.requires_convoy?(cutting_order.position.area, cutting_order.area_to)) ||
        (cutting_order.position.area == order.area_to) ||
        (cutting_order.position.player.nationality === order.position.player.nationality)
    end

    return Order::FAILED if cutting_orders.present?

    resolve_hold(order)
  end

  def resolve_hold(order)
    attack_hash = self.generate_attack_hash(order.position.area)
    area_hold_strength = self.hold_strength(order)

    if attack_hash.keys.any? { |strength_array| strength_array.first > area_hold_strength.last }
      attacking_order_key = attack_hash.keys.sort_by(&:first).last
      attacking_orders = attack_hash[attacking_order_key]
      if attacking_orders.length == 1
        attacking_order = attacking_orders.first

        # calculate reduction factor if hold order nationality is supporting the attacking order
        adjusted_attack_strength = attacking_order_key.first - self.support_reduction(attacking_order, order)

        # hold succeeds if adjusted attack strength results in hold exceeding strength, or a bounce between other attacks
        return Order::SUCCEEDED if adjusted_attack_strength <= area_hold_strength.last

        # hold fails if there is a single attacker with highest attack strength greater than hold
        # however hold succeeds if that attacker is of the same nationality
        return (attacking_order.position.player.nationality != order.position.player.nationality) ? Order::FAILED : Order::SUCCEEDED
      end
    end

    # hold succeeds if its minimum strength is greater or equal than maximum attack strength
    return Order::SUCCEEDED if attack_hash.keys.all? { |strength_array| strength_array.max <= area_hold_strength.first }

    # hold succeeds if all attacking orders fail
    return Order::SUCCEEDED if attack_hash.values.flatten.all?(&:failed?)

    nil
  end

  def resolve_convoy(order)
    disrupting_orders = @orders.select { |o| o.move? && o.area_to == order.position.area }

    # convoy fails if any attacking orders succeed
    return Order::FAILED if disrupting_orders.any?(&:succeeded?)

    # convoy succeeds if all attacking orders fail
    return Order::SUCCEEDED if disrupting_orders.all?(&:failed?)

    nil
  end

  def generate_attack_hash(area)
    @orders.select do |order|
      order.move? && (order.area_to == area)
    end.group_by do |order|
      self.attack_strength(order)
    end
  end

  def attack_strength(order)
    raise 'Attack strength not applicable to non-move orders' unless order.move?
    potential_support_orders = (@support_hash[order] || []).reject(&:failed?)
    successful_support_orders = potential_support_orders.select(&:succeeded?)
    [1 + successful_support_orders.length, 1 + potential_support_orders.length]
  end

  def hold_strength(order)
    raise 'Hold strength not applicable to move orders' if order.move?

    potential_support_orders = @orders.select(&:support?).select do |support_order|
      !support_order.failed? && (support_order.area_from == order.position.area) && (support_order.area_to == order.position.area)
    end
    successful_support_orders = potential_support_orders.select(&:succeeded?)
    [1 + successful_support_orders.length, 1 + potential_support_orders.length]
  end

  def check_bounce(move_order)
    attack_hash = self.generate_attack_hash(move_order.area_to)
    maximum_strength = attack_hash.keys.map(&:last).max
    conclusively_max_strength_orders = attack_hash[[maximum_strength, maximum_strength]]
    if conclusively_max_strength_orders.present?
      if conclusively_max_strength_orders.length > 1
        return true
      else
        return false
      end
    end
  end

  def support_reduction(attacking_order, originating_order)
    @support_hash[attacking_order]&.select do |support_order|
      support_order.succeeded? && (support_order.position.player.nationality == originating_order.position.player.nationality)
    end&.length || 0
  end

  def dislodges_own_unit?(order)
    return false unless order.support?
    return false unless (order.resolution == Order::SUCCEEDED)
    return false if (order.area_from == order.area_to)
    target_order = @orders.find { |o| o.position.area == order.area_to }
    return false if target_order.nil?
    return false if (target_order.position.player.nationality != order.position.player.nationality)
    return false if (target_order.move? && target_order.resolution == Order::SUCCEEDED)
    true
  end

  private

  def construct_incidence_matrix
    # reject failed to remove any moves that were ruled out due to invalid convoys in fail_invalid_orders
    valid_move_orders = @orders.select(&:move?).reject(&:failed?)
    @move_area_ids = valid_move_orders.pluck(:area_to_id, :area_from_id).flatten.uniq.sort
    @incidence_matrix = Array.new(@move_area_ids.size) { Array.new(@move_area_ids.size, 0) }
    return if @incidence_matrix.empty?
    valid_move_orders.each do |order|
      from_index = @move_area_ids.index(order.area_from_id)
      to_index = @move_area_ids.index(order.area_to_id)
      @incidence_matrix[from_index][to_index] = -1
      @incidence_matrix[to_index][from_index] = 1
    end
  end

  def traverse_node(node, graph, node_ids)
    graph.push(node_ids.delete(node))
    node_index = @move_area_ids.index(node)
    @incidence_matrix[node_index].each_with_index do |value, index|
      next_node = @move_area_ids[index]
      traverse_node(next_node, graph, node_ids) if value != 0 && node_ids.include?(next_node)
    end
  end

  def parse_disconnected_graphs
    node_ids = @move_area_ids.dup
    graphs = []
    while node_ids.present?
      graph = []
      traverse_node(node_ids.first, graph, node_ids)
      graphs << graph
    end
    graphs
  end

  def cyclic_graph?(graph)
    if graph.length == 2
      corresponding_orders = @orders.select { |o| graph.include?(o.position.area_id) }
      # consider graph cyclical if it is two opposing convoy orders
      return true if corresponding_orders.select { |o| o.move? && PathService.requires_convoy?(o.area_from, o.area_to) }.length == 2
    end

    # cyclic if no nodes are a sink
    graph.find do |area_id|
      index = @move_area_ids.index(area_id)
      # if no nodes are positive, that index corresponds to a sink
      @incidence_matrix[index].count(-1) == 0
    end.nil?
  end

  def dependent_orders(order)
    @orders.without(order).select do |o|
      (o.move? && o.area_to == order.position.area) ||
        ((o.support? || o.convoy?) && o.area_from == order.position.area)
    end
  end

  def dependencies_resolved?(order)
    self.dependent_orders(order).all?(&:resolved?)
  end
end
