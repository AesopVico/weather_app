class WeatherRequestService
  attr_reader :address_string
  RESPONSE_STRUCT = Struct.new(:status, :display_name, :properties)

  def initialize(street:, city:, state: zip_code:, forecast_type:)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
    @forecast_type = forecast_type
  end

  def request_weather
    location = GeocodingApiService.new(
      street: street,
      city: city,
      state: state,
      zip_code: zip_code
    ).request_coordinates
    if location.status == :success
      weather_response = WeatherApiService.new(
        lat: location.lat, 
        lon: location.lon, 
        forecast_type:forecast_type
      ).request_weather
      RESPONSE_STRUCT.new(:success, location.display_name, weather_response['properties'])
    else
      RESPONSE_STRUCT.new(location.status)
    end
  end
end