class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 1.minute, only: :create

  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(registration_params)

    if @registration.save
      start_new_session_for @registration.user
      redirect_to root_path, notice: "Welcome to FleetPilot, #{@registration.account.name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(registration: [ :account_name, :email_address, :password, :password_confirmation ])
  end
end
