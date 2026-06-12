# Demo data: one account with a small fleet. Idempotent — safe to re-run.
require "faker"

account = Account.find_or_create_by!(name: "Acme Logistics")

admin = account.users.find_or_create_by!(email_address: "admin@fleetpilot.test") do |user|
  user.password = "password123"
  user.role = :admin
end

account.users.find_or_create_by!(email_address: "viewer@fleetpilot.test") do |user|
  user.password = "password123"
  user.role = :viewer
end

MAKES_AND_MODELS = {
  "Ford" => %w[Transit F-150 Ranger],
  "Toyota" => %w[Hilux HiAce Corolla],
  "Mercedes-Benz" => %w[Sprinter Vito],
  "Chevrolet" => %w[Silverado Express]
}.freeze

VIN_CHARS = ("A".."Z").to_a - %w[I O Q] + ("0".."9").to_a

if account.vehicles.none?
  20.times do
    make = MAKES_AND_MODELS.keys.sample
    account.vehicles.create!(
      vin: Array.new(17) { VIN_CHARS.sample }.join,
      make: make,
      model: MAKES_AND_MODELS[make].sample,
      year: rand(2015..2025),
      license_plate: "#{('A'..'Z').to_a.sample(3).join}#{rand(100..999)}",
      status: [ :active, :active, :active, :in_shop, :retired ].sample,
      odometer: rand(5_000..180_000),
      fuel_type: Vehicle.fuel_types.keys.sample,
      purchased_on: Faker::Date.between(from: 8.years.ago, to: 1.year.ago),
      purchase_price_cents: rand(15_000..65_000) * 100
    )
  end
end

if account.drivers.none?
  15.times do
    account.drivers.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164,
      license_number: "DL#{rand(1_000_000..9_999_999)}",
      license_expires_on: Faker::Date.between(from: 2.months.ago, to: 4.years.from_now),
      status: rand < 0.9 ? :active : :inactive
    )
  end
end

if account.assignments.none?
  drivers = account.drivers.active.to_a.shuffle
  account.vehicles.active.limit(drivers.size).each_with_index do |vehicle, i|
    vehicle.assignments.create!(
      account: account,
      driver: drivers[i],
      started_on: Faker::Date.between(from: 18.months.ago, to: 1.month.ago)
    )
  end
end

if account.renewals.none?
  account.vehicles.find_each do |vehicle|
    Renewal.kinds.each_key do |kind|
      # Mix of valid, expiring-soon and expired dates so the alert engine has work to do.
      expires = [ rand(60..300).days.from_now, rand(1..25).days.from_now, rand(1..40).days.ago ].sample.to_date
      vehicle.renewals.create!(account:, kind:, expires_on: expires)
    end
  end
end

if account.maintenance_schedules.none?
  account.vehicles.find_each do |vehicle|
    vehicle.maintenance_schedules.create!(
      account:, category: :oil_change, interval_months: 6, interval_miles: 5_000,
      last_performed_on: rand(2..8).months.ago.to_date,
      last_performed_odometer: [ vehicle.odometer - rand(1_000..6_000), 0 ].max
    )
  end
end

if account.service_records.none?
  account.vehicles.find_each do |vehicle|
    rand(1..4).times do
      vehicle.service_records.create!(
        account:,
        category: ServiceRecord.categories.keys.sample,
        performed_on: Faker::Date.between(from: 1.year.ago, to: Date.current),
        odometer: rand(5_000..vehicle.odometer.clamp(5_000, 200_000)),
        cost_cents: rand(50..900) * 100,
        vendor: [ "Quick Lube", "City Tire", "Dealership", "Joe's Garage" ].sample
      )
    end
  end
end

# Generate the first round of alerts so the demo dashboard isn't empty.
Alerts::Scanner.call(account)

puts "Seeded: #{Account.count} accounts, #{Vehicle.count} vehicles, #{Driver.count} drivers, " \
     "#{Assignment.count} assignments, #{Renewal.count} renewals, #{ServiceRecord.count} service records, " \
     "#{Alert.active.count} open alerts"
puts "Sign in as #{admin.email_address} / password123"
