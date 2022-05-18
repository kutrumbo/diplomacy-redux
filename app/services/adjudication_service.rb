class AdjudicationService
  def initialize(orders)
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

    raise 'Adjudication did not converge' if @orders.any?(&:unresolved?)
  end

  # update resolution to failed for all orders that can be proven invalid prior to formal adjudication
  def fail_invalid_orders
    # if there is no corresponding move order for a convoy or support, mark it failed
    convoy_and_support_orders = @orders.select { |o| o.support? || o.convoy? }
    convoy_and_support_orders.each do |order|
      potential_corresponding_orders = @orders.select { |o| o.move? || o.hold? || o.support? }.without(order)
      corresponding_order = potential_corresponding_orders.find do |corresponding_order|
        if order.support? && (order.area_from == order.area_to)
          # if supporting a hold, make sure there is a corresponding hold/support order
          (corresponding_order.hold? || corresponding_order.support?) && (corresponding_order.position.area == order.area_to)
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

    from_order = @orders.find { |o| o.position.area == order.area_to }
    targest_resist_strength = if from_order.present?
      if [Order::HOLD, Order::CONVOY, Order::SUPPORT].include?(from_order.order_type)
        self.hold_strength(from_order)
      elsif (from_order.area_to == order.position.area) && !PathService.requires_convoy?(order.position.area, order.area_to)
        # head-to-head moves compete on attack strength
        self.attack_strength(from_order)
      else
        if from_order.succeeded?
          [0, 0]
        elsif from_order.failed?
          [1, 1]
        else
          # if move order from target area is unresolved, wait until it gets resolved
          return nil
        end
      end
    else
      [0, 0]
    end

    # order fails if its maximum strength is less than or equal to minimum target hold strength
    return Order::FAILED if (max_order_attack_strength <= targest_resist_strength.first)

    # order fails if it is conclusively max strength, but there are multiple max strength orders (i.e. bounce)
    return Order::FAILED if (conclusively_max_strength_orders.length > 1) && conclusively_max_strength_orders.include?(order)

    # order fails if its max strength is less than another order's minimum strength
    return Order::FAILED if sorted_attack_strengths.any? { |strength_array| max_order_attack_strength < strength_array.first }

    all_support_resolved = attack_hash.values.flatten.all? { |move_order| @support_hash[move_order].nil? || @support_hash[move_order].all?(&:resolved?) }

    # order succeeds if it is only order capable of max strength
    return Order::SUCCEEDED if all_support_resolved && (conclusively_max_strength_orders.length == 1) && (conclusively_max_strength_orders.first == order)

    nil
  end

  def resolve_support(order)
    potential_cutting_orders = @orders.select(&:move?).select do |move_order|
      move_order.area_to == order.position.area
    end

    # support order is unresolved if any potential cutting orders require a convoy but are unresolved
    return nil if potential_cutting_orders.any? { |cutting_order| cutting_order.unresolved? && PathService.requires_convoy?(cutting_order.position.area, cutting_order.area_to) }

    cutting_orders = potential_cutting_orders.reject { |cutting_order| cutting_order.failed? && PathService.requires_convoy?(cutting_order.position.area, cutting_order.area_to) }

    # support fails if there are cutting orders
    return Order::FAILED if cutting_orders.present?

    Order::SUCCEEDED
  end

  def resolve_hold(order)
    attack_hash = self.generate_attack_hash(order.position.area)
    area_hold_strength = self.hold_strength(order)

    # hold fails if its maximum strength is less than the minimum attacking strength
    # TODO: make sure not dislodged by own nationality
    return Order::FAILED if attack_hash.keys.any? { |strength_array| strength_array.first > area_hold_strength.last }

    # hold succeeds if its minimum strength is greater or equal than maximum attack strength
    return Order::SUCCEEDED if attack_hash.keys.all? { |strength_array| strength_array.max <= area_hold_strength.first }

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
    # TODO: handle attacking own nationality
    potential_support_orders = @orders.select(&:support?).select do |support_order|
      !support_order.failed? && (support_order.area_from == order.position.area) && (support_order.area_to == order.area_to)
    end
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
    else
      binding.break
    end
  end

  private

  def construct_incidence_matrix
    # reject failed to remove any moves that were ruled out due to invalid convoys in fail_invalid_orders
    @move_area_ids = @orders.select(&:move?).reject(&:failed?).pluck(:area_to_id, :area_from_id).flatten.uniq.sort
    @incidence_matrix = Array.new(@move_area_ids.size) { Array.new(@move_area_ids.size, 0) }
    return if @incidence_matrix.empty?
    @orders.select(&:move?).each do |order|
      from_index = @move_area_ids.index(order.area_from_id)
      to_index = @move_area_ids.index(order.area_to_id)
      @incidence_matrix[from_index][to_index] = -1
      @incidence_matrix[to_index][from_index] = 1
    end
    # print_incidence_matrix
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
    return true if graph.length == 2
    graph.find do |area_id|
      index = @move_area_ids.index(area_id)
      # if no nodes are positive, that index corresponds to a sink
      @incidence_matrix[index].count(-1) == 0
    end.nil?
  end
end
