require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  subject { build(:vehicle) }

  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:assignments).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:vin) }
  it { is_expected.to validate_length_of(:vin).is_equal_to(17) }
  it { is_expected.to validate_uniqueness_of(:vin).scoped_to(:account_id).ignoring_case_sensitivity }

  it "normalizes the VIN to uppercase" do
    vehicle = build(:vehicle, vin: " 1hgcm82633a004352 ")
    expect(vehicle.vin).to eq("1HGCM82633A004352")
  end

  it "rejects VINs with the forbidden characters I, O and Q" do
    vehicle = build(:vehicle, vin: "IOQCM82633A004352")
    expect(vehicle).not_to be_valid
    expect(vehicle.errors[:vin]).to be_present
  end

  it "allows the same VIN on different accounts" do
    existing = create(:vehicle)
    twin = build(:vehicle, vin: existing.vin)
    expect(twin).to be_valid
  end

  describe ".search" do
    it "matches VIN, make, model and plate" do
      vehicle = create(:vehicle, make: "Toyota", model: "Hilux", license_plate: "XYZ1234")
      create(:vehicle, account: vehicle.account, make: "Ford", model: "Transit")

      expect(Vehicle.search("hilux")).to contain_exactly(vehicle)
      expect(Vehicle.search("XYZ")).to contain_exactly(vehicle)
      expect(Vehicle.search(nil).count).to eq(2)
    end
  end

  describe "#display_name" do
    it "combines year, make and model" do
      expect(build(:vehicle, year: 2022, make: "Honda", model: "Accord").display_name).to eq("2022 Honda Accord")
    end

    it "falls back to the VIN when nothing is decoded yet" do
      vehicle = build(:vehicle, year: nil, make: nil, model: nil, vin: "1HGCM82633A004352")
      expect(vehicle.display_name).to eq("1HGCM82633A004352")
    end
  end

  describe "#current_driver" do
    it "returns the driver of the open assignment" do
      assignment = create(:assignment, started_on: 1.month.ago.to_date)
      expect(assignment.vehicle.current_driver).to eq(assignment.driver)
    end

    it "ignores ended assignments" do
      assignment = create(:assignment, started_on: 1.year.ago.to_date, ended_on: 1.month.ago.to_date)
      expect(assignment.vehicle.current_driver).to be_nil
    end
  end
end
