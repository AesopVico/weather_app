class GeocodingApiService

  GEOCODING_API_URL = "https://geocode.maps.co/search"
  RESPONSE_STRUCT = Struct.new(:lat, :lon, :place_id, :display_name)

  include ApiRequestHelper

  attr_reader :address_string

  def initialize(address_string:)
    @address_string = address_string
  end

  def request_coordinates
    response = get(url: GEOCODING_API_URL, params: query_params)
    response.map do |record|
      RESPONSE_STRUCT.new(
        record['lat'],
        record['lon'],
        record['place_id'],
        record['display_name'])
    end
    
  end

  private

  def query_params
    {
      q: address_string,
      api_key: ENV['GEOCODING_API_KEY']
    }
  end
end