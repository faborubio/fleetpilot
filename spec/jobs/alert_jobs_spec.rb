require 'rails_helper'

RSpec.describe "Alert jobs", type: :job do
  before { ActiveJob::Base.queue_adapter = :test }

  describe AccountAlertsJob do
    it "scans for alerts and enqueues the digest email" do
      account = create(:account)
      vehicle = create(:vehicle, account:)
      create(:renewal, account:, vehicle:, expires_on: 2.days.ago.to_date)
      create(:user, account:, notify_by_email: true)

      expect {
        described_class.perform_now(account)
      }.to have_enqueued_mail(AlertsMailer, :digest)

      expect(account.alerts.active.count).to eq(1)
    end
  end

  describe ScanAllAlertsJob do
    it "enqueues one AccountAlertsJob per account" do
      create_list(:account, 3)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(AccountAlertsJob).exactly(3).times
    end
  end
end
