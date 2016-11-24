require 'capybara/rspec'
require 'capybara/poltergeist'
require 'codeclimate-test-reporter'
require 'gamefic'
include Gamefic

Capybara.javascript_driver = :poltergeist
CodeClimate::TestReporter.start
