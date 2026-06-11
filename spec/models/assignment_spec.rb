require 'rails_helper'

RSpec.describe Assignment, type: :model do
  it { is_expected.to belong_to(:account) }
  it { is_expected.to belong_to(:vehicle) }
  it { is_expected.to belong_to(:driver) }
  it { is_expected.to validate_presence_of(:started_on) }

  it "rejects an end date before the start date" do
    assignment = build(:assignment, started_on: Date.current, ended_on: 1.week.ago.to_date)
    expect(assignment).not_to be_valid
    expect(assignment.errors[:ended_on]).to be_present
  end

  describe "tenant integrity" do
    it "rejects a vehicle from another account" do
      assignment = build(:assignment, vehicle: create(:vehicle))
      expect(assignment).not_to be_valid
      expect(assignment.errors[:vehicle]).to include("belongs to another account")
    end

    it "rejects a driver from another account" do
      assignment = build(:assignment, driver: create(:driver))
      expect(assignment).not_to be_valid
      expect(assignment.errors[:driver]).to include("belongs to another account")
    end
  end

  describe "overlap validation" do
    let(:existing) do
      create(:assignment, started_on: Date.new(2026, 1, 1), ended_on: Date.new(2026, 3, 31))
    end

    it "rejects a period overlapping the same vehicle" do
      conflicting = build(:assignment,
                          account: existing.account,
                          vehicle: existing.vehicle,
                          driver: create(:driver, account: existing.account),
                          started_on: Date.new(2026, 3, 1))
      expect(conflicting).not_to be_valid
      expect(conflicting.errors[:vehicle]).to include("is already assigned during this period")
    end

    it "rejects a period overlapping the same driver" do
      conflicting = build(:assignment,
                          account: existing.account,
                          vehicle: create(:vehicle, account: existing.account),
                          driver: existing.driver,
                          started_on: Date.new(2026, 2, 1), ended_on: Date.new(2026, 2, 15))
      expect(conflicting).not_to be_valid
      expect(conflicting.errors[:driver]).to include("is already assigned during this period")
    end

    it "treats an open-ended existing assignment as blocking" do
      open_ended = create(:assignment, started_on: Date.new(2026, 1, 1))
      conflicting = build(:assignment,
                          account: open_ended.account,
                          vehicle: open_ended.vehicle,
                          driver: create(:driver, account: open_ended.account),
                          started_on: Date.new(2027, 6, 1))
      expect(conflicting).not_to be_valid
    end

    it "allows back-to-back periods that do not overlap" do
      following = build(:assignment,
                        account: existing.account,
                        vehicle: existing.vehicle,
                        driver: create(:driver, account: existing.account),
                        started_on: Date.new(2026, 4, 1), ended_on: Date.new(2026, 6, 30))
      expect(following).to be_valid
    end

    it "ignores itself when updating" do
      existing.ended_on = Date.new(2026, 4, 15)
      expect(existing).to be_valid
    end
  end
end
