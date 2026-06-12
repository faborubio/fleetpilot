require 'rails_helper'

RSpec.describe MaintenanceSchedule, type: :model do
  it { is_expected.to belong_to(:vehicle) }
  it { is_expected.to belong_to(:account) }

  it "requires at least one interval" do
    schedule = build(:maintenance_schedule, interval_months: nil, interval_miles: nil)
    expect(schedule).not_to be_valid
    expect(schedule.errors[:base]).to include("set an interval in months, miles, or both")
  end

  it "is unique per vehicle and category" do
    existing = create(:maintenance_schedule, category: :oil_change)
    dup = build(:maintenance_schedule, vehicle: existing.vehicle, account: existing.account, category: :oil_change)
    expect(dup).not_to be_valid
  end

  describe "#next_due_on" do
    it "adds the month interval to the last service date" do
      schedule = build(:maintenance_schedule, interval_months: 6, last_performed_on: Date.new(2026, 1, 1))
      expect(schedule.next_due_on).to eq(Date.new(2026, 7, 1))
    end

    it "is nil without a month interval or a last service date" do
      expect(build(:maintenance_schedule, interval_months: nil, last_performed_on: Date.current).next_due_on).to be_nil
      expect(build(:maintenance_schedule, interval_months: 6, last_performed_on: nil).next_due_on).to be_nil
    end
  end

  describe "#next_due_odometer" do
    it "adds the mileage interval to the last service odometer" do
      schedule = build(:maintenance_schedule, interval_miles: 5_000, last_performed_odometer: 20_000)
      expect(schedule.next_due_odometer).to eq(25_000)
    end
  end

  describe "#due?" do
    let(:vehicle) { build_stubbed(:vehicle, odometer: 24_000) }

    it "is due when the date threshold has passed" do
      schedule = build(:maintenance_schedule, vehicle:, interval_months: 6, interval_miles: nil,
                                              last_performed_on: 7.months.ago.to_date)
      expect(schedule.due?).to be(true)
    end

    it "is due when the mileage threshold has passed" do
      schedule = build(:maintenance_schedule, vehicle:, interval_months: nil, interval_miles: 5_000,
                                              last_performed_odometer: 18_000)
      expect(schedule.due?(odometer: 24_000)).to be(true)
    end

    it "is not due when neither threshold has been reached" do
      schedule = build(:maintenance_schedule, vehicle:, interval_months: 6, interval_miles: 5_000,
                                              last_performed_on: 1.month.ago.to_date, last_performed_odometer: 23_000)
      expect(schedule.due?(odometer: 24_000)).to be(false)
    end
  end

  describe "#due_soon?" do
    let(:vehicle) { build_stubbed(:vehicle, odometer: 24_500) }

    it "is true within the lookahead window but not yet due" do
      schedule = build(:maintenance_schedule, vehicle:, interval_months: 6, interval_miles: nil,
                                              last_performed_on: (6.months.ago + 20.days).to_date)
      expect(schedule.due_soon?).to be(true)
    end

    it "is false once actually due" do
      schedule = build(:maintenance_schedule, vehicle:, interval_months: 6, interval_miles: nil,
                                              last_performed_on: 7.months.ago.to_date)
      expect(schedule.due_soon?).to be(false)
    end
  end
end
