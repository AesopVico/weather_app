RSpec.shared_context 'weather api responses' do

  let(:lat_lon_mock) do
    instance_double(
      RestClient::Response,
      body: lat_lon_body.to_json
    )
  end

  let(:lat) { rand(180) }
  let(:lon) { rand(180) }
  
  let(:lat_lon_body) do
    {
      properties: {
        forecast: Faker::Internet.domain_name,
        forecastHourly: Faker::Internet.domain_name,
        forecastGridData: Faker::Internet.domain_name
      }
    }
  end

  let(:current_utc_time) { Time.current.getutc }

  let(:rest_client_mock) do
    instance_double(
      RestClient::Response,
      body: response_body.to_json
    )
  end

  let(:current_weather_body) do
    {
      properties: {
        updateTime: current_utc_time.strftime("%Y-%m-%dT%H:%M:%S%Z"),
        temperature: {
          uom: "wmoUnit:degC",
          values: temperatures
        }
      }
    }
  end

  let(:temperatures) do
    7.times.map do |i|
      timestamp = (current_utc_time - i.hours).strftime("%Y-%m-%dT%H:%M:%S%Z")
      { validTime: timestamp, value: rand(25.0) }
    end
  end

  let(:seven_day_forecast_body) do
    {
      properties: {
        updateTime: current_utc_time.strftime("%Y-%m-%dT%H:%M:%S%Z"),
        periods: seven_day_forecast_periods
      }
    }
  end

  let(:seven_day_forecast_periods) do
    14.times.map do |i|
      is_day = i % 2 == 0 ? true : false
      {
        name: Faker::Lorem.word,
        number: i + 1,
        startTime: (current_utc_time + 12*i.hours).strftime("%Y-%m-%dT%H:%M:%S%Z"),
        isDayTime: is_day,
        temperature: rand(100),
        temperatureUnit: 'F',
        windSpeed: Faker::Lorem.sentence,
        shortForecast: Faker::Lorem.sentence,
        detailedForecast: Faker::Lorem.paragraph
      }
    end
  end

  let(:hourly_forecast_body) do
    {
      properties: {
        updateTime: current_utc_time.strftime("%Y-%m-%dT%H:%M:%S%Z"),
        periods: hourly_forecast_periods
      }
    }
  end

  let(:hourly_forecast_periods) do
    40.times.map do |i|
      is_day = i % 2 == 0 ? true : false
      {
        name: Faker::Lorem.word,
        number: i + 1,
        startTime: (current_utc_time + 12*i.hours).strftime("%Y-%m-%dT%H:%M:%S%Z"),
        isDayTime: is_day,
        temperature: rand(100),
        temperatureUnit: 'F',
        windSpeed: Faker::Lorem.sentence,
        shortForecast: Faker::Lorem.sentence,
        detailedForecast: Faker::Lorem.paragraph
      }
    end
  end
end