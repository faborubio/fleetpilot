require 'rails_helper'

RSpec.describe Alerts::Dispatcher do
  let(:account) { create(:account) }

  before { ActiveJob::Base.queue_adapter = :test }

  it "emails users who opted in and marks pending alerts as sent" do
    create(:user, account:, notify_by_email: true)
    create(:user, account:, notify_by_email: false)
    alert = create(:alert, account:, status: :pending)

    expect {
      described_class.call(account)
    }.to have_enqueued_mail(AlertsMailer, :digest).once

    expect(alert.reload.status).to eq("sent")
  end

  it "does nothing when there are no pending alerts" do
    create(:user, account:, notify_by_email: true)
    create(:alert, account:, status: :sent)

    expect { described_class.call(account) }.not_to have_enqueued_mail(AlertsMailer, :digest)
  end

  it "does not re-send alerts that were already sent" do
    create(:user, account:, notify_by_email: true)
    create(:alert, account:, status: :pending)

    described_class.call(account)
    expect { described_class.call(account) }.not_to have_enqueued_mail(AlertsMailer, :digest)
  end
end
