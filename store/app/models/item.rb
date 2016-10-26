class Item < ApplicationRecord
  has_many :orders
  has_many :reviews

  def total_ordered
    orders.sum(:quantity)
  end

  def total_revenue
    total_ordered * price
  end

  validates_presence_of :title, :category, :description, :price
end
