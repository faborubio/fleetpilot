class RenewalsController < ApplicationController
  before_action :set_vehicle, only: %i[new create]
  before_action :set_renewal, only: %i[edit update destroy]

  def new
    @renewal = @vehicle.renewals.new
    authorize @renewal
  end

  def create
    @renewal = @vehicle.renewals.new(renewal_params.merge(account: current_account))
    authorize @renewal

    if @renewal.save
      redirect_to @vehicle, notice: "Renewal added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @renewal.update(renewal_params)
      redirect_to @renewal.vehicle, notice: "Renewal updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = @renewal.vehicle
    @renewal.destroy!
    redirect_to vehicle, notice: "Renewal removed."
  end

  private

  def set_vehicle
    @vehicle = current_account.vehicles.find(params[:vehicle_id])
  end

  def set_renewal
    @renewal = current_account.renewals.find(params[:id])
    authorize @renewal
  end

  def renewal_params
    params.expect(renewal: [ :kind, :expires_on, :notes ])
  end
end
