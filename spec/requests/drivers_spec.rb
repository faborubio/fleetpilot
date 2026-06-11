require 'rails_helper'

RSpec.describe "Drivers", type: :request do
  let(:user) { create(:user) }
  let(:account) { user.account }

  it "does not expose drivers from other accounts" do
    foreign_driver = create(:driver)
    sign_in user

    get driver_path(foreign_driver)
    expect(response).to have_http_status(:not_found)
  end

  it "creates a driver" do
    sign_in user

    expect {
      post drivers_path, params: { driver: { name: "Alex Driver", email: "alex@acme.test" } }
    }.to change(account.drivers, :count).by(1)
  end

  it "forbids viewers from managing drivers" do
    sign_in create(:user, :viewer)
    driver = create(:driver, account: Account.last)

    patch driver_path(driver), params: { driver: { name: "Hacked" } }
    expect(driver.reload.name).not_to eq("Hacked")
  end
end
