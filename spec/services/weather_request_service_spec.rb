require 'rails_helper'

RSpec.describe WeatherRequestService, type: :service do
  subject(:service) { described_class.new(**params) }

  let(:params) do
    {
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code,
    }
  end

  let(:geocoding_api_response) do
    GeocodingApiService::RESPONSE_STRUCT.new(
      geocoding_response_symbol,
      rand(180),
      rand(180),
      rand(10000),
      params[:city]
    )
  end

  let(:utc_timestamp) { Time.current.getutc }

  let(:current_weather_api_response) do
    {
      last_updated: utc_timestamp,
      temperatures: temperatures
    }
  end

  let(:temperatures) do
    7.times.map do |i|
      {
        timestamp: Time.current.getutc - i.hours,
        temperature: rand(100.0)
      }
    end
  end

  let(:geocoding_response_symbol) { :success }

  let(:mock_weather_api) { instance_double(WeatherApiService) }
  let(:mock_geocoding_api) { instance_double(GeocodingApiService) }
  before do
    allow(WeatherApiService)
      .to receive(:new)
      .with(
        lat: an_instance_of(Integer),
        lon: an_instance_of(Integer)
      ).and_return(mock_weather_api)
    allow(GeocodingApiService)
      .to receive(:new)
      .with(**params)
      .and_return(mock_geocoding_api)
    allow(mock_weather_api).to receive(:current_weather).and_return(current_weather_api_response)
    allow(mock_weather_api).to receive(:ten_day_forecast)
    allow(mock_weather_api).to receive(:hourly_forecast)
    allow(mock_geocoding_api).to receive(:request_coordinates).and_return(geocoding_api_response)
  end
  describe '#request_weather' do
    subject(:response) { service.request_weather }
    it 'should return the weather properties of the requested location' do
      expect(response.status).to eq(:success)
      expect(response.display_name).to eq(params[:city])
      expect(response.current_weather).to eq(current_weather_api_response)
    end
    context 'when the location cannot be found' do
      let(:geocoding_response_symbol) { :no_location_found }
      it 'should return :no_location_found and no weather properties' do
        expect(response.status).to eq(:no_location_found)
        expect(response.display_name).to eq(nil)
        expect(response.current_weather).to eq(nil)
      end
    end
    context 'when multiple locations are found' do
      let(:geocoding_response_symbol) { :multiple_locations }
      it 'should return :multiple_locations and no weather properties' do
        expect(response.status).to eq(:multiple_locations)
        expect(response.display_name).to eq(nil)
        expect(response.current_weather).to eq(nil)
      end
    end
  end
end