require 'rails_helper'

RSpec.describe VinDecoder do
  let(:vin) { "1HGCM82633A004352" }
  let(:api_url) { "#{described_class::BASE_URL}/#{vin}?format=json" }

  it "returns make, model and year from the NHTSA payload" do
    stub_request(:get, api_url).to_return(
      status: 200,
      body: { Results: [ { "Make" => "HONDA", "Model" => "Accord", "ModelYear" => "2003" } ] }.to_json
    )

    result = described_class.decode(vin)

    expect(result.make).to eq("Honda")
    expect(result.model).to eq("Accord")
    expect(result.year).to eq(2003)
  end

  it "returns nil when the API has no data for the VIN" do
    stub_request(:get, api_url).to_return(
      status: 200,
      body: { Results: [ { "Make" => "", "Model" => "", "ModelYear" => "" } ] }.to_json
    )

    expect(described_class.decode(vin)).to be_nil
  end

  it "returns nil on HTTP errors" do
    stub_request(:get, api_url).to_return(status: 503)

    expect(described_class.decode(vin)).to be_nil
  end

  it "returns nil on timeouts" do
    stub_request(:get, api_url).to_timeout

    expect(described_class.decode(vin)).to be_nil
  end
end
