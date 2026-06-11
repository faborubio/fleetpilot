# Decodes a VIN against the free NHTSA vPIC API and returns the vehicle's
# make, model and year. Returns nil when the VIN cannot be decoded.
#
# API docs: https://vpic.nhtsa.dot.gov/api/
class VinDecoder
  BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues".freeze
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10

  Result = Data.define(:make, :model, :year)

  def self.decode(vin)
    new(vin).decode
  end

  def initialize(vin)
    @vin = vin
  end

  def decode
    row = fetch
    return nil if row.nil? || row["Make"].blank?

    Result.new(
      make: row["Make"].titleize,
      model: row["Model"].presence,
      year: row["ModelYear"].presence&.to_i
    )
  end

  private

  attr_reader :vin

  def fetch
    uri = URI("#{BASE_URL}/#{URI.encode_uri_component(vin)}?format=json")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                               open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
      http.get(uri.request_uri)
    end
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("Results", 0)
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, JSON::ParserError => e
    Rails.logger.warn("VIN decode failed for #{vin}: #{e.class} #{e.message}")
    nil
  end
end
