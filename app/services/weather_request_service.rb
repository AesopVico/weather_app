class WeatherRequestService

  attr_reader :street, :city, :state, :zip_code

  attr_accessor(
    :status, 
    :display_name, 
    :current_weather, 
    :current_forecast, 
    :seven_day_forecast, 
    :hourly_forecast
  )

  def initialize(street: nil, city: nil, state: nil, zip_code: nil)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end

  def request_weather
    # get the lat/lon for a given address
    @status = coordinates_info_for_address.status
    if @status  == :success
      collate_seven_day_forecast
      @display_name = coordinates_info_for_address.display_name
      @current_weather = request_current_weather
      @hourly_forecast = request_hourly_weather
    end
  end

  private

  def collate_seven_day_forecast
    raw_forecast = request_seven_day_forecast
    
    @current_forecast = raw_forecast[:forecasts].find { |forecast| forecast[:number] == 1 }
    @seven_day_forecast = raw_forecast[:forecasts].group_by do |forecast|
      Time.parse(forecast[:start_time]).to_date
    end
  end

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