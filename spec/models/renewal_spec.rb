require 'rails_helper'

RSpec.describe Renewal, type: :model do
  it { is_expected.to belong_to(:vehicle) }
  it { is_expected.to validate_presence_of(:expires_on) }

  it "is unique per vehicle and kind" do
    existing = create(:renewal, kind: :insurance)
    dup = build(:renewal, vehicle: existing.vehicle, account: existing.account, kind: :insurance)
    expect(dup).not_to be_valid
  end

  describe "#expired?" do
    it "is true the day after expiry" do
      expect(build(:renewal, expires_on: Date.yesterday).expired?).to be(true)
    end

    it "is false on the expiry day" do
      expect(build(:renewal, expires_on: Date.current).expired?).to be(false)
    end
  end

  describe "#due_soon?" do
    it "is true within 30 days of expiry" do
      expect(build(:renewal, expires_on: 10.days.from_now.to_date).due_soon?).to be(true)
    end

    it "is false when expiry is far away" do
      expect(build(:renewal, expires_on: 90.days.from_now.to_date).due_soon?).to be(false)
    end

    it "is false once already expired" do
      expect(build(:renewal, expires_on: 1.day.ago.to_date).due_soon?).to be(false)
    end
  end
end
