class AdjudicationService
  def initialize(orders)
    @orders = orders
    @orders_by_type = @orders.group_by(&:order_type)
    @resolution_hash = @orders.reduce({}) do |hash, order|
      hash[order] = Resolution.new(order: order, status: Resolution::UNRESOLVED)
      hash
    end
    @positions = @orders.map(&:position)
    @order_to_hash = @orders.group_by(&:area_to)
  end

  def adjudicate
    self.fail_invalid_orders
    iterations = 0
    while (@resolution_hash.values.any?(&:unresolved?) && (iterations < 10)) do
      @resolution_hash.values.select(&:unresolved?).each do |resolution|
        resolution.status = self.resolve_order(resolution.order)
      end
      iterations += 1
    end
    raise 'Adjudication did not converge' if @resolution_hash.values.any?(&:unresolved?)
    @resolution_hash
  end

  # update resolution to failed for all orders that can be proven invalid prior to normal adjudication
  def fail_invalid_orders
    # if there is no corresponding move order for a convoy or support, mark it failed
    convoy_and_support_orders = [@orders_by_type[Order::SUPPORT], @orders_by_type[Order::CONVOY]].compact.flatten
    convoy_and_support_orders.each do |order|
      move_and_hold_orders = [@orders_by_type[Order::MOVE], @orders_by_type[Order::HOLD]].compact.flatten
      corresponding_order = move_and_hold_orders.find do |move_or_hold_order|
        if order.support? && (order.area_from == order.area_to)
          move_or_hold_order.hold? && (move_or_hold_order.position.area == order.area_to)
        else
          (move_or_hold_order.position.area == order.area_from) && (move_or_hold_order.area_to == order.area_to)
        end
      end
      @resolution_hash[order].status = Resolution::FAILED if corresponding_order.nil?
    end
    # if a move that requires a convoy does not have the required convoys, mark it failed
    (@orders_by_type[Order::MOVE] || []).select { |order| PathService.requires_convoy?(order.position.area, order.area_to) }.each do |order|
      valid_paths = PathService.possible_paths(order.position, @positions.without(order.position)).select do |path|
        (path.first == order.position.area) && (path.last == order.area_to)
      end.select do |path|
        convoy_areas = path.slice(1, path.length - 2)
        convoy_areas.all? do |convoy_area|
          convoy_order = @orders_by_type[Order::CONVOY].find { |convoy_order| convoy_order.position.area == convoy_area }
          convoy_order.present? && (convoy_order.area_from == order.position.area) && (convoy_order.area_to == order.area_to)
        end
      end
      @resolution_hash[order].status = Resolution::FAILED if valid_paths.empty?
    end
  end

  def resolve_order(order)
    case order.order_type
    when Order::MOVE
      destinations = PathService.possible_paths(order.position, @positions.without(order.position)).map do |path|
        path.last.is_a?(Array) ? path.last.first : path.last
      end.uniq
      if destinations.include?(order.area_to)
        Resolution::SUCCEEDED
      else
        Resolution::FAILED
      end
    when Order::SUPPORT
      Resolution::SUCCEEDED
    when Order::CONVOY
      Resolution::SUCCEEDED
    else
      raise "Unsupported order type: #{order.order_type}"
    end
  end
end
