class WeatherController < ApplicationController

  def index
    @cached = Rails.cache.exist?(cache_key)
    @weather_data = Rails.cache.fetch(cache_key, :expires => 30.minutes) do
      service = WeatherRequestService.new(
        street: filtered_params['street'],
        city: filtered_params['city'],
        state: filtered_params['state'],
        zip_code: filtered_params['zip_code'],
      )
      service.request_weather
      service
    end
    redirect_to root_path, notice: "location not found" unless @weather_data.status == :success
  end

  private

  def filtered_params
    params.permit(:street, :city, :state, :zip_code)
  end

  def cache_key
    "cached_zip_code_response/#{filtered_params[:zip_code]}"
  end

end