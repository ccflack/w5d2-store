class Item < ApplicationRecord
  has_many :orders
  has_many :reviews
end
