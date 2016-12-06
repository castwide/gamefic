require 'capybara/rspec'
require 'capybara/poltergeist'
require 'simplecov'
require 'gamefic'
include Gamefic

Capybara.javascript_driver = :poltergeist
SimpleCov.start
