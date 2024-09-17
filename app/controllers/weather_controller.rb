class WeatherController < ApplicationController

  def index
    service = WeatherRequestService.new(
      street: filtered_params['street'],
      city: filtered_params['city'],
      state: filtered_params['state'],
      zip_code: filtered_params['zip_code'],
      forecast_type: :default
    )
    @weather_data = service.request_weather
    respond_to do |format|
      format.html { render html: @weather_data }
    end
  end

  private

  def filtered_params
    params.permit(:street, :city, :state, :zip_code, :forecast_type)
  end

end