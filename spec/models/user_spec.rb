require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to belong_to(:account) }
  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
  it { is_expected.to define_enum_for(:role).with_values(viewer: 0, manager: 1, admin: 2) }

  it "normalizes the email address" do
    user = create(:user, email_address: "  Fleet.Admin@EXAMPLE.com ")
    expect(user.email_address).to eq("fleet.admin@example.com")
  end

  it "defaults to the viewer role" do
    expect(User.new.role).to eq("viewer")
  end
end
