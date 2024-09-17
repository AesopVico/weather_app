class WeatherApiService

  include ApiRequestHelper

  NWS_API_URL = "https://api.weather.gov/points/".freeze

  attr_reader :lat, :lon, :unit

  def initialize(lat:, lon:, unit: :farenheit)
    @lat = lat
    @lon = lon
    @unit = unit
  end

  def current_weather
    api_response = get(url: grid_urls[:grid_data])['properties']
    parse_current_weather(api_response: api_response)
  end

  def ten_day_forecast
    get(url: grid_urls[:ten_day])['properties']
  end

  def hourly_forecast
    get(url: grid_urls[:hourly])['properties']
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
      grid_data: properties['forecastGridData']
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

  def parse_forecast

  end

  def format_current_temp_info(temp_info:)
    {
      timestamp: DateTime.parse(temp_info['validTime']),
      temperature: unit == :farenheit ? (temp_info['value'] * 1.8) + 32 : temp_info['value']
    }
  end
end