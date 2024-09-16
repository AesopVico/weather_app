require 'rails_helper'

RSpec.describe WeatherApiService, type: :service do
  subject(:service) { described_class.new(lat: lat, lon: lon, forecast_type: forecast_type) }
  let(:url) { "#{WeatherApiService::NWS_API_URL}#{lat},#{lon}" }
  let(:lat_lon_mock) do
    instance_double(
      RestClient::Response,
      body: lat_lon_body.to_json
    )
  end

  let(:lat) { rand(180) }
  let(:lon) { rand(180) }
  let(:forecast_type) { :default }
  
  let(:lat_lon_body) do
    {
      properties: {
        forecast: Faker::Internet.domain_name,
        forecastHourly: Faker::Internet.domain_name,
        forecastGridData: Faker::Internet.domain_name
      }
    }
  end

  let(:grid_data_mock) do
    instance_double(
      RestClient::Response,
      body: grid_data_body
    )
  end

  let(:grid_data_body) do
    {
      foo: 'bar'
    }.to_json
  end

  describe 'request_weather' do
    subject(:response) { service.request_weather }
    context 'with default forecast' do

      before do
        expect(RestClient).to receive(:get).with(url, {}).and_return(lat_lon_mock)
        expect(RestClient).to receive(:get).with(lat_lon_body[:properties][:forecast], {}).and_return(grid_data_mock)
      end

      it 'should request the appropriate resources based on the request' do
        expect(response['foo']).to eq('bar')
      end

    end

    context 'with hourly forecast' do
      let(:forecast_type) { :hourly }

      before do
        expect(RestClient).to receive(:get).with(url, {}).and_return(lat_lon_mock)
        expect(RestClient).to receive(:get).with(lat_lon_body[:properties][:forecastHourly], {}).and_return(grid_data_mock)
      end

      it 'should request the appropriate resources based on the request' do
        expect(response['foo']).to eq('bar')
      end

    end

    context 'with grid data forecast' do
      let(:forecast_type) { :grid_data }

      before do
        expect(RestClient).to receive(:get).with(url, {}).and_return(lat_lon_mock)
        expect(RestClient).to receive(:get).with(lat_lon_body[:properties][:forecastGridData], {}).and_return(grid_data_mock)
      end

      it 'should request the appropriate resources based on the request' do
        expect(response['foo']).to eq('bar')
      end

    end
  end
end