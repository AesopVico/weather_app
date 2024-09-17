RSpec.shared_context 'weather api responses' do

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
      properties: {
        updateTime: Time.current.getutc.strftime("%Y-%m-%dT%H:%M:%S%Z"),
        temperature: {
          uom: "wmoUnit:degC",
          values: temperatures
        }
      }
    }.to_json
  end

  let(:temperatures) do
    7.times.map do |i|
      timestamp = (Time.now - i.hours).getutc.strftime("%Y-%m-%dT%H:%M:%S%Z")
      { validTime: timestamp, value: rand(25.0) }
    end
  end


end