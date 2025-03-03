class HolidaysController < ApplicationController
  include HolidaysHelper

  before_action :authorize_global
  before_action :find_contract, only: [:index, :new, :create]
  before_action :find_holiday, only: [:edit, :update, :destroy]

  def index
    @holidays = @contract.holidays.order(:date)
  end

  def new
    @holiday = @contract.holidays.new
  end

  def create
    @holiday = @contract.holidays.new(holiday_params)
    if @holiday.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to contract_holiday_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @holiday.update(holiday_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to contract_holiday_path
    else
      render :edit
    end
  end

  def destroy
    @holiday.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_holiday_path
  end

  private

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end

  def find_holiday
    @holiday = Holiday.find(params[:id])
  end

  def holiday_params
    params[:holiday].permit(:date, :description)
  end

end
