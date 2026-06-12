class DriversController < ApplicationController
  before_action :set_driver, only: %i[show edit update destroy]

  def index
    authorize Driver
    drivers = current_account.drivers.search(params[:q])
    drivers = drivers.where(status: params[:status]) if params[:status].present?
    @pagy, @drivers = pagy(drivers.order(:name))
  end

  def show
    @assignments = @driver.assignments.includes(:vehicle).order(started_on: :desc)
  end

  def new
    @driver = current_account.drivers.new
    authorize @driver
  end

  def create
    @driver = current_account.drivers.new(driver_params)
    authorize @driver

    if @driver.save
      redirect_to @driver, notice: "Driver added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @driver.update(driver_params)
      redirect_to @driver, notice: "Driver updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @driver.destroy!
    redirect_to drivers_path, notice: "Driver removed."
  end

  private

  def set_driver
    @driver = current_account.drivers.find(params[:id])
    authorize @driver
  end

  def driver_params
    params.expect(driver: [ :name, :email, :phone, :license_number, :license_expires_on, :status ])
  end
end
