class ServiceRecordsController < ApplicationController
  before_action :set_vehicle, only: %i[new create]

  def new
    @service_record = @vehicle.service_records.new(performed_on: Date.current, odometer: @vehicle.odometer)
    authorize @service_record
  end

  def create
    @service_record = @vehicle.service_records.new(service_record_params.merge(account: current_account))
    authorize @service_record

    if @service_record.save
      redirect_to @vehicle, notice: "Service record added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @service_record = current_account.service_records.find(params[:id])
    authorize @service_record
    vehicle = @service_record.vehicle
    @service_record.destroy!
    redirect_to vehicle, notice: "Service record removed."
  end

  private

  def set_vehicle
    @vehicle = current_account.vehicles.find(params[:vehicle_id])
  end

  def service_record_params
    params.expect(service_record: [ :category, :performed_on, :odometer, :cost_cents, :vendor, :notes ])
  end
end
