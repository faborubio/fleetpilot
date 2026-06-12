require 'rails_helper'

RSpec.describe Driver, type: :model do
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:assignments).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }

  it "rejects malformed emails but allows blank ones" do
    expect(build(:driver, email: "not-an-email")).not_to be_valid
    expect(build(:driver, email: "")).to be_valid
  end

  describe "#license_expired?" do
    it "is true when the expiry date is in the past" do
      expect(build(:driver, license_expires_on: Date.yesterday).license_expired?).to be(true)
    end

    it "is false when there is no expiry date or it is in the future" do
      expect(build(:driver, license_expires_on: nil).license_expired?).to be(false)
      expect(build(:driver, license_expires_on: Date.tomorrow).license_expired?).to be(false)
    end
  end
end
