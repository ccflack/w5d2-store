class ItemsController < ApplicationController
  def index
    ROOT
    GET   '/items'              => 'items#index', as: :items
    GET   '/items/new'          => 'items#new', as: :new_item
    POST  '/items'              => 'items#create'
    GET   '/items/:id/edit'     => 'itesm#edit', as: :edit_item
    PATCH '/items/:id'          => 'items#update',

  end
end
