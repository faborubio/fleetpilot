require 'rails_helper'

RSpec.describe "Assignments", type: :request do
  let(:user) { create(:user) }
  let(:account) { user.account }
  let(:vehicle) { create(:vehicle, account: account) }
  let(:driver) { create(:driver, account: account) }

  before { sign_in user }

  it "assigns a driver to a vehicle" do
    expect {
      post assignments_path, params: { assignment: {
        vehicle_id: vehicle.id, driver_id: driver.id, started_on: Date.current
      } }
    }.to change(account.assignments, :count).by(1)

    expect(response).to redirect_to(vehicle_path(vehicle))
  end

  it "rejects overlapping assignments with an error" do
    create(:assignment, account: account, vehicle: vehicle, driver: driver, started_on: 1.month.ago.to_date)
    other_driver = create(:driver, account: account)

    expect {
      post assignments_path, params: { assignment: {
        vehicle_id: vehicle.id, driver_id: other_driver.id, started_on: Date.current
      } }
    }.not_to change(Assignment, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("already assigned")
  end

  it "cannot reference a vehicle from another account" do
    foreign_vehicle = create(:vehicle)

    expect {
      post assignments_path, params: { assignment: {
        vehicle_id: foreign_vehicle.id, driver_id: driver.id, started_on: Date.current
      } }
    }.not_to change(Assignment, :count)

    expect(response).to have_http_status(:not_found)
  end
end
