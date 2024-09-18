class WeatherRequestService

  # these values are immutable and only set on initialization
  attr_reader :street, :city, :state, :zip_code

  attr_accessor(
    :status, # Geocoding Status, used to determine if request is valid
    :display_name, # display name of address provided
    :current_weather, # Current Weather for the requested location
    :current_forecast, # Current forecast for the requested location
    :seven_day_forecast, # Seven day forecast, grouped by date
    :hourly_forecast, # Hourly forecast, limited to 24 hours
  )

  def initialize(street: nil, city: nil, state: nil, zip_code: nil)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end

  # Wrapper method, makes requests to the API services to get all the information
  def request_weather
    # get the lat/lon for a given address
    @status = coordinates_info_for_address.status
    # only continue if the coordinates are valid
    if @status  == :success
      # 
      collate_seven_day_forecast
      @display_name = coordinates_info_for_address.display_name
      @current_weather = request_current_weather
      @hourly_forecast = request_hourly_weather
    end
  end

  private
  # Identifies and sets the current forecast, as well as group the full set as days
  def collate_seven_day_forecast
    # get the forecast from the WeatherApiService
    raw_forecast = request_seven_day_forecast
    
    @current_forecast = raw_forecast[:forecasts].find { |forecast| forecast[:number] == 1 }
    @seven_day_forecast = raw_forecast[:forecasts].group_by do |forecast|
      Time.parse(forecast[:start_time]).to_date
    end
  end

  # Requests current weather from WeatherApiService.
  def request_current_weather
    weather_api_service.current_weather
  end

  # Requests Seven Day forecast from WeatherApiService
  def request_seven_day_forecast
    weather_api_service.seven_day_forecast
  end

  # Requests Hourly forecast from WeatherApiService
  def request_hourly_weather
    weather_api_service.hourly_forecast
  end

  # Memoized API response from the Geocoding API. Allows for the
  # coordinate data to be requested once and returned 
  def coordinates_info_for_address
    @coordinates_info_for_address ||= GeocodingApiService.new(
      street: street,
      city: city,
      state: state,
      zip_code: zip_code
    ).request_coordinates
  end
  # Memoized service object, allows for multiple requests to be processed by
  # the same insance of the WeatherApiService
  def weather_api_service
    @weather_api_response ||= WeatherApiService.new(
      lat: coordinates_info_for_address.lat, 
      lon: coordinates_info_for_address.lon
    )
  end
end