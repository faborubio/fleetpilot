class MaintenanceSchedulesController < ApplicationController
  before_action :set_vehicle, only: %i[new create]
  before_action :set_schedule, only: %i[edit update destroy]

  def new
    @maintenance_schedule = @vehicle.maintenance_schedules.new
    authorize @maintenance_schedule
  end

  def create
    @maintenance_schedule = @vehicle.maintenance_schedules.new(schedule_params.merge(account: current_account))
    authorize @maintenance_schedule

    if @maintenance_schedule.save
      redirect_to @vehicle, notice: "Maintenance schedule added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @maintenance_schedule.update(schedule_params)
      redirect_to @maintenance_schedule.vehicle, notice: "Maintenance schedule updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = @maintenance_schedule.vehicle
    @maintenance_schedule.destroy!
    redirect_to vehicle, notice: "Maintenance schedule removed."
  end

  private

  def set_vehicle
    @vehicle = current_account.vehicles.find(params[:vehicle_id])
  end

  def set_schedule
    @maintenance_schedule = current_account.maintenance_schedules.find(params[:id])
    authorize @maintenance_schedule
  end

  def schedule_params
    params.expect(maintenance_schedule: [ :category, :interval_months, :interval_miles,
                                          :last_performed_on, :last_performed_odometer ])
  end
end
