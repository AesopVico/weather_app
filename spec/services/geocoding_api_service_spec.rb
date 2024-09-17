require 'rails_helper'

RSpec.describe GeocodingApiService, type: :service do
  subject(:service) do
    described_class.new(**params)
  end

  let(:params) do
    {
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code
    }
  end

  let(:rest_client_mock) do 
    instance_double(
      RestClient::Response,
      body: response_body
    )
  end

  let(:geocoding_response) do
    {
      lat: rand(180),
      lon: rand(180),
      place_id: rand(10000),
      display_name: params[:city]
    }
  end

  let(:response_body) { [geocoding_response].to_json }

  describe '#request_coordinates' do
    subject(:response) { service.request_coordinates }
    before do
      expect(RestClient).to receive(:get).and_return(rest_client_mock)
    end
    it 'should return a correctly formatted Struct' do
      expect(response.status).to eq(:success)
      expect(response.lat).to eq(geocoding_response[:lat])
      expect(response.lon).to eq(geocoding_response[:lon])
      expect(response.place_id).to eq(geocoding_response[:place_id])
      expect(response.display_name).to eq(geocoding_response[:display_name])
    end
    context 'with multiple locations returned by the Geocoding API' do
      let(:response_body) { [geocoding_response, geocoding_response].to_json }

      it 'should return a correctly formatted Struct' do
        expect(response.status).to eq(:multiple_locations)
        expect(response.lat).to eq(nil)
        expect(response.lon).to eq(nil)
        expect(response.place_id).to eq(nil)
        expect(response.display_name).to eq(nil)
      end
    end

    context 'with multiple locations returned by the Geocoding API' do
      let(:response_body) { [].to_json }

      it 'should return a correctly formatted Struct' do
        expect(response.status).to eq(:no_location_found)
        expect(response.lat).to eq(nil)
        expect(response.lon).to eq(nil)
        expect(response.place_id).to eq(nil)
        expect(response.display_name).to eq(nil)
      end
    end
  end

end