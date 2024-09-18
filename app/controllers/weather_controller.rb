class WeatherController < ApplicationController

  def index
    @cached = Rails.cache.exist?(filtered_params[:zip_code])
    @weather_data = Rails.cache.fetch(filtered_params[:zip_code], :expires => 30.minutes) do
      service = WeatherRequestService.new(
        street: filtered_params['street'],
        city: filtered_params['city'],
        state: filtered_params['state'],
        zip_code: filtered_params['zip_code'],
      )
      service.request_weather
    end
  end

  private

  def filtered_params
    params.permit(:street, :city, :state, :zip_code)
  end

end