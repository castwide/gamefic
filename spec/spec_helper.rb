require 'capybara/rspec'
require 'capybara/poltergeist'
require 'codeclimate-test-reporter'

Capybara.javascript_driver = :poltergeist
CodeClimate::TestReporter.start
