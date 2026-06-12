require 'rails_helper'

RSpec.describe "Maintenance resources", type: :request do
  let(:user) { create(:user) }
  let(:account) { user.account }
  let(:vehicle) { create(:vehicle, account:) }

  before { sign_in user }

  describe "service records" do
    it "logs a service record under a vehicle" do
      expect {
        post vehicle_service_records_path(vehicle), params: { service_record: {
          category: "oil_change", performed_on: Date.current, odometer: 31_000, cost_cents: 9_500
        } }
      }.to change(vehicle.service_records, :count).by(1)

      expect(response).to redirect_to(vehicle_path(vehicle))
    end

    it "cannot attach a record to another account's vehicle" do
      foreign = create(:vehicle)
      post vehicle_service_records_path(foreign), params: { service_record: { performed_on: Date.current } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "renewals" do
    it "adds a renewal" do
      expect {
        post vehicle_renewals_path(vehicle), params: { renewal: { kind: "insurance", expires_on: 1.year.from_now.to_date } }
      }.to change(vehicle.renewals, :count).by(1)
    end
  end

  describe "maintenance schedules" do
    it "adds a schedule" do
      expect {
        post vehicle_maintenance_schedules_path(vehicle), params: { maintenance_schedule: {
          category: "oil_change", interval_months: 6, interval_miles: 5_000
        } }
      }.to change(vehicle.maintenance_schedules, :count).by(1)
    end

    it "rejects a schedule with no interval" do
      post vehicle_maintenance_schedules_path(vehicle), params: { maintenance_schedule: { category: "brakes" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "authorization" do
    it "forbids viewers from logging service" do
      sign_in create(:user, :viewer)
      own_vehicle = create(:vehicle, account: User.last.account)

      expect {
        post vehicle_service_records_path(own_vehicle), params: { service_record: { performed_on: Date.current } }
      }.not_to change(ServiceRecord, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
