# NWS does not support physical addresses for weather requests,
# so we are requesting the latitude and longitude for the desired
# address
class GeocodingApiService

  GEOCODING_API_URL = "https://geocode.maps.co/search"
  # I am using a Struct because the current implementation is relatively simple,
  # but if any computational 
  RESPONSE_STRUCT = Struct.new(:status, :lat, :lon, :place_id, :display_name)

  include ApiRequestHelper

  attr_reader :street, :city, :state, :zip_code

  def initialize(street:, city:, state:, zip_code:)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end

  def request_coordinates
    response = get(url: GEOCODING_API_URL, params: query_params)
    case response.length
    when 0
      RESPONSE_STRUCT.new(:no_location_found)
    when 1
      coordinate_data = response[0]
      RESPONSE_STRUCT.new(
        :success, 
        coordinate_data['lat'],
        coordinate_data['lon'],
        coordinate_data['place_id'],
        coordinate_data['display_name']
      )
    else
      RESPONSE_STRUCT.new(:multiple_locations)
    end
  end

  private

  def query_params
    {
      street: street,
      city: city,
      state: state,
      postalcode: zip_code,
      country: 'US',
      api_key: ENV['GEOCODING_API_KEY']
    }
  end
end