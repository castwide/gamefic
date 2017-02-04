require 'rubygems'
require 'bundler/setup'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'simplecov'
require 'gamefic'
require 'gamefic-sdk'
include Gamefic

Capybara.javascript_driver = :poltergeist
SimpleCov.start
