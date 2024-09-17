class WeatherRequestService

  attr_reader :street, :city, :state, :zip_code, :forecast_type

  RESPONSE_STRUCT = Struct.new(:status, :display_name, :current_weather, :seven_day_forecast, :hourly_forecast)

  def initialize(street:, city:, state:, zip_code:)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end

  def request_weather
    # get the lat/lon for a given address
    if coordinates_info_for_address.status == :success
      RESPONSE_STRUCT.new(
        coordinates_info_for_address.status, 
        coordinates_info_for_address.display_name, 
        request_current_weather,
        request_seven_day_forecast,
        request_hourly_weather
      )
    else
      # either too many locations found or none were found, return the status
      # to the caller
      RESPONSE_STRUCT.new(coordinates_info_for_address.status)
    end
  end

  private

  def request_current_weather
    weather_api_service.current_weather
  end

  def request_seven_day_forecast
    weather_api_service.seven_day_forecast
  end

  def request_hourly_weather
    weather_api_service.hourly_forecast
  end

  def coordinates_info_for_address
    @coordinates_info_for_address ||= GeocodingApiService.new(
      street: street,
      city: city,
      state: state,
      zip_code: zip_code
    ).request_coordinates
  end

  def weather_api_service
    @weather_api_response ||= WeatherApiService.new(
      lat: coordinates_info_for_address.lat, 
      lon: coordinates_info_for_address.lon
    )
  end
end