require 'rails_helper'

RSpec.describe "Onboarding", type: :system do
  it "signs up a company and adds the first vehicle" do
    visit new_registration_path

    fill_in "Company name", with: "Acme Fleet Co"
    fill_in "Email", with: "owner@acme.test"
    fill_in "Password", with: "password123", match: :prefer_exact
    fill_in "Confirm password", with: "password123"
    click_button "Create account"

    expect(page).to have_content("Welcome to FleetPilot, Acme Fleet Co!")
    expect(page).to have_content("No vehicles found")

    click_link "Add vehicle"
    fill_in "VIN", with: "1HGCM82633A004352"
    fill_in "Odometer (mi)", with: "42000"
    click_button "Create Vehicle"

    expect(page).to have_content("Vehicle added")
    expect(page).to have_content("1HGCM82633A004352")
  end
end
