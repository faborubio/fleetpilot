require 'rails_helper'

RSpec.describe Alerts::Scanner do
  let(:account) { create(:account) }
  let(:vehicle) { create(:vehicle, account:, odometer: 50_000) }

  describe "renewals" do
    it "raises a critical alert for an expired renewal" do
      renewal = create(:renewal, account:, vehicle:, kind: :insurance, expires_on: 5.days.ago.to_date)

      described_class.call(account)

      alert = renewal.alerts.sole
      expect(alert).to have_attributes(category: "renewal_expired", severity: "critical", status: "pending")
    end

    it "raises a warning for a renewal expiring soon" do
      renewal = create(:renewal, account:, vehicle:, expires_on: 10.days.from_now.to_date)
      described_class.call(account)
      expect(renewal.alerts.sole.category).to eq("renewal_due_soon")
    end

    it "creates no alert for a renewal far in the future" do
      create(:renewal, account:, vehicle:, expires_on: 1.year.from_now.to_date)
      described_class.call(account)
      expect(account.alerts).to be_empty
    end
  end

  describe "maintenance" do
    it "raises a warning when a schedule is due" do
      schedule = create(:maintenance_schedule, account:, vehicle:, interval_miles: 5_000,
                                               interval_months: nil, last_performed_odometer: 44_000)
      described_class.call(account)
      expect(schedule.alerts.sole.category).to eq("maintenance_due")
    end
  end

  describe "driver licenses" do
    it "raises a critical alert for an expired license" do
      driver = create(:driver, account:, license_expires_on: 1.day.ago.to_date)
      described_class.call(account)
      expect(driver.alerts.sole).to have_attributes(category: "license_expired", severity: "critical")
    end

    it "ignores drivers without a license expiry date" do
      create(:driver, account:, license_expires_on: nil)
      described_class.call(account)
      expect(account.alerts).to be_empty
    end
  end

  describe "idempotency and reconciliation" do
    it "does not duplicate alerts across runs" do
      create(:renewal, account:, vehicle:, expires_on: 5.days.ago.to_date)
      expect { 2.times { described_class.call(account) } }.to change { account.alerts.count }.by(1)
    end

    it "updates the message in place when the underlying date changes" do
      renewal = create(:renewal, account:, vehicle:, expires_on: 5.days.ago.to_date)
      described_class.call(account)
      original = renewal.alerts.sole

      renewal.update!(expires_on: 10.days.ago.to_date)
      described_class.call(account)

      updated = renewal.alerts.active.sole
      expect(updated.id).to eq(original.id)
      expect(updated.message).to include(10.days.ago.to_date.to_fs(:long))
      expect(updated.message).not_to eq(original.message)
    end

    it "dismisses the alert once the condition clears" do
      renewal = create(:renewal, account:, vehicle:, expires_on: 5.days.ago.to_date)
      described_class.call(account)

      renewal.update!(expires_on: 1.year.from_now.to_date)
      described_class.call(account)

      expect(renewal.alerts.active).to be_empty
      expect(renewal.alerts.status_dismissed).to be_present
    end

    it "swaps due_soon for expired as time passes" do
      renewal = create(:renewal, account:, vehicle:, expires_on: 10.days.from_now.to_date)
      described_class.call(account)
      expect(renewal.alerts.active.sole.category).to eq("renewal_due_soon")

      renewal.update!(expires_on: 1.day.ago.to_date)
      described_class.call(account)

      expect(renewal.alerts.active.sole.category).to eq("renewal_expired")
    end
  end
end
