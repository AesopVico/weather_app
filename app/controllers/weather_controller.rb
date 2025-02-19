class WeatherController < ApplicationController

  def index
    # Boolean value that determines whether the response is cached or fresh
    @cached = Rails.cache.exist?(cache_key)
    # Sets @weather_data to either a fresh instance or a cached instance
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
    # if the service returns anything other than a success, redirect to the home page
    redirect_to root_path, notice: "location not found" unless @weather_data.status == :success
  end

  private
  # allow only the params we need for the request
  def filtered_params
    params.permit(:street, :city, :state, :zip_code)
  end

  # reusable cache key for lookup
  def cache_key
    "cached_zip_code_response/#{filtered_params[:zip_code]}"
  end

end