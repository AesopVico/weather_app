require 'rails_helper'

RSpec.describe WeatherApiService, type: :service do
  subject(:service) { described_class.new(lat: lat, lon: lon) }
  let(:url) { "#{WeatherApiService::NWS_API_URL}#{lat},#{lon}" }

  include_context 'weather api responses'

  before do
    expect(RestClient)
      .to receive(:get)
      .with(url, params: {})
      .and_return(lat_lon_mock)
  end
  describe 'current_weather' do
    subject(:response) { service.current_weather }

    let(:response_body) { current_weather_body }

    before do
      expect(RestClient)
        .to receive(:get)
        .with(lat_lon_body[:properties][:forecastGridData], params: {})
        .and_return(rest_client_mock)
    end

    it 'should request the current weather for the specified location' do
      expect(response[:last_updated]).to be_a(DateTime)
      expect(response[:temperatures]).to be_a(Array)
    end
  end

  describe '#seven_day_forecast' do
  subject(:response) { service.seven_day_forecast }

  let(:response_body) { seven_day_forecast_body }

    before do
      expect(RestClient)
        .to receive(:get)
        .with(lat_lon_body[:properties][:forecast], params: {})
        .and_return(rest_client_mock)
    end
    it 'should request the ten day forecast for the specified location' do
      expect(response[:last_updated]).to be_a(DateTime)
      expect(response[:forecasts]).to be_a(Array)
      expect(response[:forecasts].length).to eq(14)
    end
  end

  describe '#hourly_forecast' do
  subject(:response) { service.hourly_forecast }

  let(:response_body) { hourly_forecast_body }

    before do
      expect(RestClient)
        .to receive(:get)
        .with(lat_lon_body[:properties][:forecastHourly], params: {})
        .and_return(rest_client_mock)
    end
    it 'should request the ten day forecast for the specified location' do
      expect(response[:last_updated]).to be_a(DateTime)
      expect(response[:forecasts]).to be_a(Array)
      expect(response[:forecasts].length).to eq(24)
    end
  end

end