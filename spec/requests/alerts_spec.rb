require 'rails_helper'

RSpec.describe "Alerts", type: :request do
  let(:user) { create(:user) }
  let(:account) { user.account }

  before { sign_in user }

  it "lists active alerts only" do
    create(:alert, account:, message: "Insurance expired", status: :pending)
    create(:alert, account:, message: "Old dismissed thing", status: :dismissed)

    get alerts_path
    expect(response.body).to include("Insurance expired")
    expect(response.body).not_to include("Old dismissed thing")
  end

  it "dismisses an alert via turbo stream" do
    alert = create(:alert, account:, status: :pending)

    delete alert_path(alert), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(alert.reload.status).to eq("dismissed")
  end

  it "does not expose another account's alert" do
    foreign = create(:alert)
    delete alert_path(foreign)
    expect(response).to have_http_status(:not_found)
  end

  it "forbids viewers from dismissing" do
    sign_in create(:user, :viewer)
    alert = create(:alert, account: User.last.account, status: :pending)

    delete alert_path(alert)
    expect(alert.reload.status).to eq("pending")
  end
end
