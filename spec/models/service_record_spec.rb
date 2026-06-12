require 'rails_helper'

RSpec.describe ServiceRecord, type: :model do
  it { is_expected.to belong_to(:vehicle) }
  it { is_expected.to validate_presence_of(:performed_on) }

  describe "syncing the matching maintenance schedule" do
    it "updates the schedule's last-performed markers on the same category" do
      vehicle = create(:vehicle, odometer: 40_000)
      schedule = create(:maintenance_schedule, vehicle:, account: vehicle.account,
                                               category: :oil_change, last_performed_odometer: 20_000)

      create(:service_record, vehicle:, account: vehicle.account,
                              category: :oil_change, performed_on: Date.current, odometer: 40_000)

      expect(schedule.reload.last_performed_odometer).to eq(40_000)
      expect(schedule.last_performed_on).to eq(Date.current)
    end

    it "leaves schedules of other categories untouched" do
      vehicle = create(:vehicle)
      schedule = create(:maintenance_schedule, vehicle:, account: vehicle.account,
                                               category: :tires, last_performed_odometer: 10_000)

      create(:service_record, vehicle:, account: vehicle.account, category: :oil_change, odometer: 50_000)

      expect(schedule.reload.last_performed_odometer).to eq(10_000)
    end
  end
end
