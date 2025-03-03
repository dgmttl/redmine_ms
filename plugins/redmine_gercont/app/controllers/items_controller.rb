class ItemsController < ApplicationController
  include ItemsHelper

  before_action :authorize_global
  before_action :find_contract, only: [:index, :new, :create]
  before_action :find_item, only: [:edit, :update, :destroy]

  def index
    @items = @contract.items
  end

  def new
    @item = @contract.items.new
  end

  def create
    @item = @contract.items.new(item_params)
    if @item.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to contract_catalog_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to contract_catalog_path
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_catalog_path
  end

  private

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end

  def find_item
    @item = Item.find(params[:id])
  end

  def item_params
    params[:item].permit(:name, :description, :unit_measure, :unit_value)
  end

end