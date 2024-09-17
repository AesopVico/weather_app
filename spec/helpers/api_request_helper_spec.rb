# require './app/helpers/api_request_helper'
require 'rails_helper'

class Helper
  include ApiRequestHelper
end

RSpec.describe ApiRequestHelper, type: :helper do
  attr_reader :helper

  before do
    @helper = Helper.new
  end

  let(:rest_client_mock) do
    instance_double(
      RestClient::Response,
      body: {
        foo: 'bar',
        baz: 'zip'
      }.to_json
    )
  end

  let(:url) { "test.com" }
  let(:test_params) { { quix: 'flux', hello: 'world' } }
  
  describe '#get' do
    context 'with only request URL present' do   
      subject(:response) { helper.get(url: url) }
      before do
        expect(RestClient).to receive(:get).with(url, params: {}).and_return(rest_client_mock)
      end
      it 'returns the body of an API response' do
        expect(response['foo']).to eq('bar')
        expect(response['baz']).to eq('zip')
      end
    end

    context 'with query params and URL present' do
      subject(:response) { helper.get(url: url, params: params) }
      before do
        expect(RestClient).to receive(:get).with(url, params: params).and_return(rest_client_mock)
      end
      it 'returns the body of an API response' do
        expect(response['foo']).to eq('bar')
        expect(response['baz']).to eq('zip')
      end
    end
  end
end