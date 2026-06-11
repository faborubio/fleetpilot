require 'rails_helper'

RSpec.describe VinDecodeJob do
  let(:vehicle) { create(:vehicle, make: nil, model: nil, year: nil) }

  it "fills in blank attributes from the decoder" do
    allow(VinDecoder).to receive(:decode).with(vehicle.vin)
      .and_return(VinDecoder::Result.new(make: "Honda", model: "Accord", year: 2003))

    described_class.perform_now(vehicle)

    expect(vehicle.reload).to have_attributes(make: "Honda", model: "Accord", year: 2003)
  end

  it "does not overwrite user-entered data" do
    vehicle.update!(make: "Custom Make")
    allow(VinDecoder).to receive(:decode)
      .and_return(VinDecoder::Result.new(make: "Honda", model: "Accord", year: 2003))

    described_class.perform_now(vehicle)

    expect(vehicle.reload.make).to eq("Custom Make")
    expect(vehicle.model).to eq("Accord")
  end

  it "leaves the vehicle untouched when decoding fails" do
    allow(VinDecoder).to receive(:decode).and_return(nil)

    expect { described_class.perform_now(vehicle) }.not_to change { vehicle.reload.updated_at }
  end
end
