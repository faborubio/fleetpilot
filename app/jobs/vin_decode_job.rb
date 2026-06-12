# Fills in make/model/year from the NHTSA vPIC API after a vehicle is created.
# Never overwrites data the user typed in.
class VinDecodeJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer, attempts: 3

  def perform(vehicle)
    result = VinDecoder.decode(vehicle.vin)
    return if result.nil?

    vehicle.with_lock do
      vehicle.make = result.make if vehicle.make.blank?
      vehicle.model = result.model if vehicle.model.blank?
      vehicle.year = result.year if vehicle.year.blank?
      vehicle.save!
    end
  end
end
