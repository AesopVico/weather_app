class WeatherApiService

  include ApiRequestHelper

  NWS_API_URL = "https://api.weather.gov/points/".freeze

  attr_reader :lat, :lon, :forecast_type

  def initialize(lat:, lon:, forecast_type: :default)
    @lat = lat
    @lon = lon
    @forecast_type = forecast_type
  end

  def request_weather
    grid_info = request_grid_info_by_lat_lon
    properties = get(url: grid_info[forecast_type])
  end

  private

  def parse_response

  end
  # NWS weather data is returned by using proprietary grids that cover 2.5km x 2.5km
  # Using the latitude and longitude of the requested location, we can request the grid info
  # along with the resource paths for the requested grid
  def request_grid_info_by_lat_lon
    url = NWS_API_URL + "#{lat},#{lon}"
    properties = get(url: url)['properties']
    {
      default: properties['forecast'],
      hourly: properties['forecastHourly'],
      grid_data: properties['forecastGridData']
    }
  end

end