class WeatherRequestService

  attr_reader :street, :city, :state, :zip_code, :forecast_type

  RESPONSE_STRUCT = Struct.new(:status, :display_name, :properties)

  def initialize(street:, city:, state:, zip_code:, forecast_type:)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
    @forecast_type = forecast_type
  end

  def request_weather
    # get the lat/lon for a given address
    location_data = get_coordinates_for_address
    if location_data.status == :success
      weather_data = get_weather(location_data: location_data)
      RESPONSE_STRUCT.new(:success, location_data.display_name, weather_data.properties)
    else
      # either too many locations found or none were found, return the status
      # to the caller
      RESPONSE_STRUCT.new(location_data.status)
    end
  end

  private

  def get_coordinates_for_address
    GeocodingApiService.new(
      street: street,
      city: city,
      state: state,
      zip_code: zip_code
    ).request_coordinates
  end

  def get_weather(location_data:)
    WeatherApiService.new(
      lat: location_data.lat, 
      lon: location_data.lon, 
      forecast_type:forecast_type
    ).request_weather
  end
end