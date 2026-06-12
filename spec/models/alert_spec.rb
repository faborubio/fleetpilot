require 'rails_helper'

RSpec.describe Alert, type: :model do
  it { is_expected.to belong_to(:alertable) }
  it { is_expected.to validate_presence_of(:message) }

  describe "scopes" do
    it ".active excludes dismissed alerts" do
      pending_alert = create(:alert, status: :pending)
      create(:alert, status: :dismissed)
      expect(Alert.active).to contain_exactly(pending_alert)
    end

    it ".by_urgency orders critical first, then by due date" do
      account = create(:account)
      info = create(:alert, account:, severity: :info, due_on: Date.current)
      critical = create(:alert, account:, severity: :critical, due_on: 1.week.from_now.to_date)
      expect(Alert.where(account:).by_urgency.to_a).to eq([ critical, info ])
    end
  end

  it "#dismiss! marks the alert dismissed" do
    alert = create(:alert, status: :pending)
    expect { alert.dismiss! }.to change(alert, :status).from("pending").to("dismissed")
  end
end
