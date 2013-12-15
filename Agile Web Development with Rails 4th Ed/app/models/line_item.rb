class LineItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :product
  belongs_to :cart

  attr_accessible :product_id, :product, :cart_id, :quantity, :cart

  def total_price
    product.price * quantity
  end

end
