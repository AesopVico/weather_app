ENV['RAILS_ENV'] ||= 'test' 
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'contexts/weather_api_responses.rb'
# require 'rspec/mocks'
# require 'capybara/rspec'Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
