class WeatherApiService

  include ApiRequestHelper

  NWS_API_URL = "https://api.weather.gov/points/".freeze
  HOURLY = 'Hourly'.freeze
  SEVEN_DAY = 'Seven Day'.freeze

  attr_reader :lat, :lon, :unit

  def initialize(lat:, lon:, unit: :farenheit)
    @lat = lat
    @lon = lon
    @unit = unit
  end

  def current_weather
    api_response = get(url: grid_urls[:current])['properties']
    parse_current_weather(api_response: api_response)
  end

  def seven_day_forecast
    api_response = get(url: grid_urls[:ten_day])['properties']
    parse_forecast(api_response: api_response, forecast_type: SEVEN_DAY)
  end

  def hourly_forecast
    api_response = get(url: grid_urls[:hourly])['properties']
    parse_forecast(api_response: api_response, forecast_type: HOURLY)
  end

  private
  # NWS weather data is returned by using proprietary grids that cover 2.5km x 2.5km
  # Using the latitude and longitude of the requested location, we can request the grid info
  # along with the resource paths for the requested grid
  def grid_urls
    return @grid_urls if defined?(@grid_urls)

    url = NWS_API_URL + "#{lat},#{lon}"
    properties = get(url: url)['properties']
    @grid_urls = {
      # 10 day forecast
      ten_day: properties['forecast'],
      # hourly forecast
      hourly: properties['forecastHourly'],
      # grid data is current weather and historical data
      current: properties['forecastGridData']
    }
  end

  def parse_current_weather(api_response:)
    update_time = DateTime.parse(api_response['updateTime'])
    updated_temps = api_response['temperature']['values'].select do |temp_info|
      DateTime.parse(temp_info['validTime']) < update_time
    end
    
    {
      last_updated: update_time,
      temperatures: updated_temps.map { |temp_info| format_current_temp_info(temp_info: temp_info) }
    }
  end

  def parse_forecast(api_response:, forecast_type:)
    {
      forecast_type: forecast_type,
      last_updated: DateTime.parse(api_response['updateTime']),
      # limit the number of periods to 24, hourly has 156 total periods returned in the response
      forecasts: api_response['periods'].first(24).map { |period| transform_keys(period: period) }
    }
  end

  def transform_keys(period:)
    period.transform_keys { |key| key.underscore.to_sym }
  end

  def format_current_temp_info(temp_info:)
    {
      timestamp: DateTime.parse(temp_info['validTime']),
      temperature: unit == :farenheit ? (temp_info['value'] * 1.8) + 32 : temp_info['value']
    }
  end
end