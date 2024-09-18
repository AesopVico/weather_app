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

  let(:seven_day_api_response) do
    {
      forecast_type: 'Seven Day',
      last_updated: utc_timestamp,
      forecasts: periods
    }
  end

  let(:hourly_api_response) do
    {
      forecast_type: 'Hourly',
      last_updated: utc_timestamp,
      forecasts: periods
    }
  end

  let(:periods) do
    14.times.map do |i|
      is_day = i % 2 == 0 ? true : false
      {
        name: Faker::Lorem.word,
        number: i + 1,
        start_time: (utc_timestamp + 12*i.hours).strftime("%Y-%m-%dT%H:%M:%S%Z"),
        is_day_time: is_day,
        temperature: rand(100),
        temperature_unit: 'F',
        wind_speed: Faker::Lorem.sentence,
        short_forecast: Faker::Lorem.sentence,
        detailed_forecast: Faker::Lorem.paragraph
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
    allow(mock_weather_api).to receive(:seven_day_forecast).and_return(seven_day_api_response)
    allow(mock_weather_api).to receive(:hourly_forecast).and_return(hourly_api_response)
    allow(mock_geocoding_api).to receive(:request_coordinates).and_return(geocoding_api_response)
  end
  describe '#request_weather' do
    subject(:response) do
      service.request_weather
      service
    end

    context 'when the request is valid' do
      it { expect(response.status).to eq(:success) }
      it { expect(response.display_name).to eq(params[:city]) }
      it { expect(response.current_weather).to eq(current_weather_api_response) }
      it { expect(response.seven_day_forecast).to be_a(Hash) }
      it { expect(response.hourly_forecast).to eq(hourly_api_response) }
    end
    
    context 'when the location cannot be found' do
      let(:geocoding_response_symbol) { :no_location_found }

      it { expect(response.status).to eq(:no_location_found) }
      it { expect(response.display_name).to eq(nil) }
      it { expect(response.current_weather).to eq(nil) }
      it { expect(response.seven_day_forecast).to eq(nil) }
      it { expect(response.hourly_forecast).to eq(nil) }
    end
    context 'when multiple locations are found' do
      let(:geocoding_response_symbol) { :multiple_locations }
      
      it { expect(response.status).to eq(:multiple_locations) }
      it { expect(response.display_name).to eq(nil) }
      it { expect(response.current_weather).to eq(nil) }
      it { expect(response.seven_day_forecast).to eq(nil) }
      it { expect(response.hourly_forecast).to eq(nil) }
    end
  end
end