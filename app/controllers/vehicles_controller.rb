class VehiclesController < ApplicationController
  before_action :set_vehicle, only: %i[show edit update destroy]

  def index
    authorize Vehicle
    vehicles = current_account.vehicles.search(params[:q])
    vehicles = vehicles.where(status: params[:status]) if params[:status].present?
    @pagy, @vehicles = pagy(vehicles.order(created_at: :desc))
  end

  def show
    @assignments = @vehicle.assignments.includes(:driver).order(started_on: :desc)
    @service_records = @vehicle.service_records.recent_first.limit(20)
    @maintenance_schedules = @vehicle.maintenance_schedules.order(:category)
    @renewals = @vehicle.renewals.order(:expires_on)
  end

  def new
    @vehicle = current_account.vehicles.new
    authorize @vehicle
  end

  def create
    @vehicle = current_account.vehicles.new(vehicle_params)
    authorize @vehicle

    if @vehicle.save
      VinDecodeJob.perform_later(@vehicle)
      redirect_to @vehicle, notice: "Vehicle added. Make, model and year will be filled in from the VIN shortly."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: "Vehicle updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy!
    redirect_to vehicles_path, notice: "Vehicle removed."
  end

  private

  def set_vehicle
    @vehicle = current_account.vehicles.find(params[:id])
    authorize @vehicle
  end

  def vehicle_params
    params.expect(vehicle: [ :vin, :make, :model, :year, :license_plate, :status,
                             :odometer, :fuel_type, :purchased_on, :purchase_price_cents ])
  end
end
