class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[edit update destroy]

  def new
    @assignment = current_account.assignments.new(
      vehicle_id: params[:vehicle_id], driver_id: params[:driver_id], started_on: Date.current
    )
    authorize @assignment
  end

  def create
    @assignment = current_account.assignments.new(assignment_params)
    authorize @assignment

    if @assignment.save
      redirect_to @assignment.vehicle, notice: "Driver assigned."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to @assignment.vehicle, notice: "Assignment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = @assignment.vehicle
    @assignment.destroy!
    redirect_to vehicle, notice: "Assignment removed."
  end

  private

  def set_assignment
    @assignment = current_account.assignments.find(params[:id])
    authorize @assignment
  end

  def assignment_params
    permitted = params.expect(assignment: [ :vehicle_id, :driver_id, :started_on, :ended_on ])
    # Resolve associations through the tenant so foreign ids can't escape the account.
    permitted.merge(
      vehicle: current_account.vehicles.find(permitted[:vehicle_id]),
      driver: current_account.drivers.find(permitted[:driver_id])
    ).except(:vehicle_id, :driver_id)
  end
end
