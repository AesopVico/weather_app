class WeatherRequestService
  attr_reader :address_string
  RESPONSE_STRUCT = Struct.new(:display_name, :properties)

  def initialize(address_string:)
    @address_string = address_string
  end

  def request_weather
    locations = GeocodingApiService.new(address_string: address_string).request_coordinates
    locations.map do |location|
      weather_response = WeatherApiService.new(lat: location.lat, lon: location.lon).request_weather
      RESPONSE_STRUCT.new(location.display_name, weather_response['properties'])
    end
  end
end