class WeatherApiService

  # Shared API request functionality is defined here
  include ApiRequestHelper

  # Constants are used here to prevent "Magic Strings" being present in methods
  NWS_API_URL = "https://api.weather.gov/points/".freeze
  HOURLY = 'Hourly'.freeze
  SEVEN_DAY = 'Seven Day'.freeze

  attr_reader :lat, :lon, :unit

  def initialize(lat:, lon:, unit: :farenheit)
    @lat = lat
    @lon = lon
    @unit = unit
  end

  # request the current weather from NWS, then parse the response to
  # be more readily usable
  def current_weather
    api_response = get(url: grid_urls[:current])['properties']
    parse_current_weather(api_response: api_response)
  end
  # request the Seven Day forecast from NWS, then parse the response to
  # be more readily usable
  def seven_day_forecast
    api_response = get(url: grid_urls[:ten_day])['properties']
    parse_forecast(api_response: api_response, forecast_type: SEVEN_DAY)
  end
  # request the Hourly forecast from NWS, then parse the response to
  # be more readily usable
  def hourly_forecast
    api_response = get(url: grid_urls[:hourly])['properties']
    parse_forecast(api_response: api_response, forecast_type: HOURLY)
  end

  private
  # Memoized request for grid forecast urls. NWS forecasts must be requested 
  # using their proprietary grid system. The appropriate grid can be found using
  # the Lat/Long provided. From here, we parse the response for the resource
  # urls for the current weather and forecasts
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

  # parses the current weather response from the NWS API. Filters out any rows in the 
  # future, as we will be using the forecasts for predictions
  def parse_current_weather(api_response:)
    update_time = DateTime.parse(api_response['updateTime'])
    # select only the rows that are in the past
    updated_temps = api_response['temperature']['values'].select do |temp_info|
      # Not an optimized solution, but it works
      DateTime.parse(temp_info['validTime']) < Time.current
    end
    # return a hash containing the last update time and temperature history
    {
      last_updated: update_time,
      temperatures: updated_temps
        .map { |temp_info| format_current_temp_info(temp_info: temp_info) }
        .reverse
    }
  end
  
  # format the forecast into a more readily usable format. Seven Day and Hourly forecasts
  # use the same response structure, so both are parsed the same way
  def parse_forecast(api_response:, forecast_type:)
    {
      # identifier of forecast type
      forecast_type: forecast_type,
      last_updated: DateTime.parse(api_response['updateTime']),
      # limit the number of periods to 24, hourly has 156 total periods returned in the response
      forecasts: api_response['periods'].first(24).map { |period| transform_keys(period: period) }
    }
  end
  
  # transforms hash keys from camel case strings to snake case symbols
  def transform_keys(period:)
    period.transform_keys { |key| key.underscore.to_sym }
  end

  # Converts temperature from Celsius to Farenheit if needed
  def format_current_temp_info(temp_info:)
    {
      timestamp: DateTime.parse(temp_info['validTime']),
      temperature: unit == :farenheit ? (temp_info['value'] * 1.8) + 32 : temp_info['value']
    }
  end
end