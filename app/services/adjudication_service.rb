class AdjudicationService
  def initialize(orders)
    @orders = orders
    @orders_by_type = @orders.group_by(&:order_type)
    @positions = @orders.map(&:position)
    @order_to_hash = @orders.group_by(&:area_to)
  end

  def adjudicate
    self.fail_invalid_orders
    iterations = 0
    while (@orders.any?(&:unresolved?) && (iterations < 10)) do
      @orders.select(&:unresolved?).each do |order|
        self.resolve_order(order)
      end
      iterations += 1
    end
    raise 'Adjudication did not converge' if @orders.any?(&:unresolved?)
  end

  # update resolution to failed for all orders that can be proven invalid prior to formal adjudication
  def fail_invalid_orders
    # if there is no corresponding move order for a convoy or support, mark it failed
    convoy_and_support_orders = [@orders_by_type[Order::SUPPORT], @orders_by_type[Order::CONVOY]].compact.flatten
    convoy_and_support_orders.each do |order|
      potential_corresponding_orders = [@orders_by_type[Order::MOVE], @orders_by_type[Order::HOLD], @orders_by_type[Order::SUPPORT]].compact.flatten.without(order)
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
    @orders_by_type[Order::MOVE]&.select { |order| PathService.requires_convoy?(order.position.area, order.area_to) }.each do |order|
      valid_paths = PathService.possible_paths(order.position, @positions.without(order.position)).select do |path|
        (path.first == order.position.area) && (path.last == order.area_to)
      end.select do |path|
        convoy_areas = path.slice(1, path.length - 2)
        convoy_areas.all? do |convoy_area|
          convoy_order = @orders_by_type[Order::CONVOY].find { |convoy_order| convoy_order.position.area == convoy_area }
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
      Order::SUCCEEDED
    when Order::CONVOY
      Order::SUCCEEDED
    when Order::HOLD
      Order::SUCCEEDED
    else
      raise "Unsupported order type: #{order.order_type}"
    end
  end

  def resolve_move(order)
    destinations = PathService.possible_paths(order.position, @positions.without(order.position)).map do |path|
      path.last.is_a?(Array) ? path.last.first : path.last
    end.uniq
    if !destinations.include?(order.area_to)
      Order::FAILED
    else
      attack_hash = self.generate_attack_hash(order.area_to)
      sorted_attack_strengths = attack_hash.keys.sort_by { |strength| strength.last }.reverse
      max_attack_strength = sorted_attack_strengths.first.last
      conclusively_max_strength_orders = attack_hash.select do |strength_array|
        strength_array.first == max_attack_strength
      end.values.flatten

      # subject order succeeds if it is only order capable of max strength
      return Order::SUCCEEDED if conclusively_max_strength_orders.length == 1 && (conclusively_max_strength_orders.first == order)

      # subject order fails if it is conclusively max strength, but there are multiple max strength orders (i.e. bounce)
      return Order::FAILED if (conclusively_max_strength_orders.length > 1) && conclusively_max_strength_orders.include?(order)

      order_attack_strength = attack_hash.keys.find { |strength_array| attack_hash[strength_array].include?(order) }
      max_order_attack_strength = order_attack_strength.last

      # subject order fails if its max strength is less than another order's minimum strength
      return Order::FAILED if sorted_attack_strengths.any? { |strength_array| max_order_attack_strength < strength_array.first }

      Order::UNRESOLVED
    end
  end

  def generate_attack_hash(area)
    @orders_by_type[Order::MOVE].select do |order|
      order.area_to == area
    end.group_by do |order|
      self.attack_strength(order)
    end
  end

  def attack_strength(order)
    raise 'Attack strength not applicable to non-move orders' unless order.move?
    # TODO: handle attacking own nationality
    potential_support_orders = @orders_by_type[Order::SUPPORT]&.select do |support_order|
      !support_order.failed? && (support_order.area_from == order.position.area) && (support_order.area_to == order.area_to)
    end || []
    successful_support_orders = potential_support_orders.select(&:succeeded?)
    [1 + successful_support_orders.length, 1 + potential_support_orders.length]
  end

  def hold_strength(order)
    # TODO
  end

  def prevent_strength(area)
    # TODO
  end

  def defend_strength(area)
    # TODO
  end
end
