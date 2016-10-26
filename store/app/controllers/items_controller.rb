class ItemsController < ApplicationController

  # ROOT
  # GET   '/items'              => 'items#index', as: :items
    #displays a table showing all the existing items (with their title, description, category, price [in dollars and cents], and total quantity ordered) and a button to create a new one
  # GET   '/items/new'          => 'items#new', as: :new_item
    # displays a form to create a new item. It should have fields for title, description, category and price (in cents)
  # POST  '/items'              => 'items#create'
  #  creates a new item, and once it saves it the database, redirects to the root_url
  # GET   '/items/:id/edit'     => 'itesm#edit', as: :edit_item
    # displays a form to edit an existing item. It should have the same fields as the new form, but the values are for that existing item
  # PATCH '/items/:id'          => 'items#update',
    #Updates the items with that :id and then redirects to the front.

    # Each item should have a link/button to edit that particular item.
    # Make it look decent (this is code for bootstrap ... use the bootstrap-sass gem)

    before_action :find_item, only: [:edit, :update]

  def index
    @colums = Item.column_names
    @items = Item.left_joins(:orders).group(:id).order('SUM (orders.quantity) DESC')
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    render :new
  end

  def update
    @item.update(item_params)
    redirect_to root_path
  end

  private

  def find_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :category, :description, :price)
  end


end
