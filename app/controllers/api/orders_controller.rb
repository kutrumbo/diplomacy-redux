module Api
  class OrdersController < ApplicationController
    def adjudicate
      orders = params[:orders].map do |order_hash|
        Order.new(
          id: order_hash[:id],
          position: Position.new(
            nationality: order_hash[:nationality],
            area_id: order_hash[:area],
            unit_type: order_hash[:unit_type],
          ),
          order_type: order_hash[:order_type],
          area_from_id: order_hash[:area_from],
          area_to_id: order_hash[:area_to],
        )
      end

      AdjudicationService.new(orders).adjudicate

      render json: orders
    end
  end
end
