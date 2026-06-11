require 'rails_helper'

RSpec.describe "Vehicles", type: :request do
  let(:user) { create(:user) }
  let(:account) { user.account }

  describe "authentication" do
    it "redirects unauthenticated visitors to sign in" do
      get vehicles_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "tenant isolation" do
    it "does not expose vehicles from other accounts" do
      foreign_vehicle = create(:vehicle)
      sign_in user

      get vehicle_path(foreign_vehicle)
      expect(response).to have_http_status(:not_found)
    end

    it "lists only the account's vehicles" do
      mine = create(:vehicle, account: account, make: "Toyota", model: "Hilux")
      create(:vehicle, make: "Ford", model: "Ranger")
      sign_in user

      get vehicles_path
      expect(response.body).to include(mine.vin)
      expect(response.body).not_to include("Ranger")
    end
  end

  describe "CRUD" do
    before { sign_in user }

    it "creates a vehicle and enqueues VIN decoding" do
      expect {
        post vehicles_path, params: { vehicle: { vin: "1hgcm82633a004352", odometer: 100 } }
      }.to change(account.vehicles, :count).by(1)
        .and have_enqueued_job(VinDecodeJob)

      expect(account.vehicles.last.vin).to eq("1HGCM82633A004352")
    end

    it "re-renders the form on validation errors" do
      post vehicles_path, params: { vehicle: { vin: "short" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates a vehicle" do
      vehicle = create(:vehicle, account: account)
      patch vehicle_path(vehicle), params: { vehicle: { status: "in_shop" } }
      expect(vehicle.reload.status).to eq("in_shop")
    end

    it "destroys a vehicle" do
      vehicle = create(:vehicle, account: account)
      expect { delete vehicle_path(vehicle) }.to change(account.vehicles, :count).by(-1)
    end

    it "filters by search and status" do
      hilux = create(:vehicle, account: account, make: "Toyota", model: "Hilux", status: :in_shop)
      create(:vehicle, account: account, make: "Toyota", model: "Corolla", status: :active)

      get vehicles_path, params: { q: "toyota", status: "in_shop" }
      expect(response.body).to include(hilux.vin)
      expect(response.body).not_to include("Corolla")
    end
  end

  describe "authorization" do
    it "forbids viewers from creating vehicles" do
      sign_in create(:user, :viewer)

      expect {
        post vehicles_path, params: { vehicle: { vin: "1HGCM82633A004352" } }
      }.not_to change(Vehicle, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
