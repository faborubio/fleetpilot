require "rails_helper"

RSpec.describe AlertsMailer, type: :mailer do
  describe "#digest" do
    let(:account) { create(:account) }
    let(:user) { create(:user, account:) }

    it "lists the alerts and addresses the recipient" do
      alerts = [
        create(:alert, account:, severity: :critical, message: "Insurance expired"),
        create(:alert, account:, severity: :warning, message: "Oil change due", alertable: create(:maintenance_schedule, account:))
      ]

      mail = described_class.digest(user, alerts.map(&:id))

      expect(mail.to).to eq([ user.email_address ])
      expect(mail.subject).to include("2 fleet alerts")
      expect(mail.body.encoded).to include("Insurance expired").and include("Oil change due")
    end

    it "is not delivered when there are no alerts" do
      mail = described_class.digest(user, [])
      expect(mail.to).to be_nil
    end
  end
end
