require 'rails_helper'

RSpec.describe WeatherApiService, type: :service do
  subject(:service) { described_class.new(lat: lat, lon: lon) }
  let(:url) { "#{WeatherApiService::NWS_API_URL}#{lat},#{lon}" }

  include_context 'weather api responses'

  describe 'current_weather' do

    before do
      expect(RestClient)
        .to receive(:get)
        .with(url, params: {})
        .and_return(lat_lon_mock)
      expect(RestClient)
        .to receive(:get)
        .with(lat_lon_body[:properties][:forecastGridData], params: {})
        .and_return(grid_data_mock)
    end

    subject(:response) { service.current_weather }
    
    before do

    end

    it 'should request the current weather based on the request' do
      expect(response[:last_updated]).to be_a(DateTime)
      expect(response[:temperatures]).to be_a(Array)
    end
  end
end