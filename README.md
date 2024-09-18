# Weather App

## Description

A simple, lightweight forecast app that provides the current temperature and forecasts for a provided location, built completely in Ruby on Rails.

## Requirements

- GitHub
- Ruby 3.3.4
- Rails 7.1.3

## External Resources

- [National Weather Service API](https://www.weather.gov/documentation/services-web-api)
- [Geocoding API](https://geocode.maps.co/)

### Required Accounts

- Geocoding API
  
  - provides API key for Address lookup

## Local Setup

1. Clone the repository
1. Install bundled gems using `bundle install`
1. Copy `.env.sample` and name it `.env`
1. Replace `GEOCODING_API_KEY` with your key provided by Geocoding API
1. run the server using `rails s`

## How it Works

At a high level, when an address is provided by the user, we pass that address to the Geocoding API to get the latitude and longitude of the physical address. From there, we make a request to the NWS Weather API for the current weather, as well as hourly and seven day forecasts.

### Why use Geocoding?

The NWS API only supports grid lookups using global coordinates. This requires us to get these coordinates from a separate service.

## Known issues

- Only supports forecasts for the United States
  - Solution: Change weather API source for international requests
- No integration tests using Capybara
- The controller is caching the entire service instead of just the requests from the API
  - While this does technically work, it is much more memory-intensive than just caching the API responses
  - Solution: cache each API response in the WeatherRequestService and have that determine whether a cache was loaded
- Response from the `GeocodingApiService` uses a struct.
  - While this works, I would prefer to use `attr_accessor` similarly the the `WeatherRequestService` or create a dedicated response object.
- Temperature unit is always Farenheit

## Future Goals

- Display more weather datapoints, such as chance of precipitation, humidity, dewpoints, etc.
- Use JavaScript to toggle visibility of the seven day and hourly forecasts.
- Preserve the provided address info in the form so the user does not have to re-enter it.
- Move the logic determining day and night from the view to the service
- Optimize current weather parsing functionality to be less CPU intensive