require 'rails_helper'

RSpec.describe "Assigning drivers", type: :system do
  it "assigns a driver to a vehicle from the vehicle page" do
    user = create(:user)
    vehicle = create(:vehicle, account: user.account, make: "Toyota", model: "Hilux", year: 2023)
    driver = create(:driver, account: user.account, name: "Alex Driver")

    sign_in user

    visit vehicle_path(vehicle)
    expect(page).to have_content("No drivers have been assigned")

    click_link "Assign driver"
    select "2023 Toyota Hilux", from: "Vehicle"
    select "Alex Driver", from: "Driver"
    fill_in "From", with: Date.current
    click_button "Create Assignment"

    expect(page).to have_content("Driver assigned")
    expect(page).to have_content("Alex Driver")
    expect(page).to have_content("Current")

    expect(driver.reload.current_vehicle).to eq(vehicle)
  end
end
