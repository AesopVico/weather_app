# NWS does not support physical addresses for weather requests,
# so we are requesting the latitude and longitude for the desired
# address
class GeocodingApiService

  GEOCODING_API_URL = "https://geocode.maps.co/search"
  # This initial implementation uses a Struct for responses. The preferred solution
  # is either to use attr_accessor or create a dedicated response service object
  RESPONSE_STRUCT = Struct.new(:status, :lat, :lon, :place_id, :display_name)

  # Shared API request functionality is defined here
  include ApiRequestHelper

  attr_reader :street, :city, :state, :zip_code

  def initialize(street: nil, city: nil, state: nil, zip_code: nil)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end

  # request the lat/lon coordinates for a physical address
  def request_coordinates
    # Makes a GET request to the Geocoding API
    response = get(url: GEOCODING_API_URL, params: query_params)
    # If the response length does not equal one, do not attempt to 
    # process the response and return a non-success symbol
    case response.length
    when 0
      RESPONSE_STRUCT.new(:no_location_found)
    when 1
      coordinate_data = response[0]
      # Build out the response struct and return all necessary data points
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
  
  # builds the query param hash to be provided to the Geocoding API
  def query_params
    {
      street: street,
      city: city,
      state: state,
      postalcode: zip_code,
      country: 'US',
      # Obfuscated environment variable
      api_key: ENV['GEOCODING_API_KEY']
    }
  end
end