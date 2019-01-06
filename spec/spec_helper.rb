require 'rubygems'
require 'bundler/setup'
require 'capybara/rspec'
require 'simplecov'
require 'gamefic'
require 'gamefic-sdk'
require 'sinatra/base'
require 'gamefic-library-standard'

SimpleCov.start

class TestFileServer < Rack::File
  attr_writer :root
  def initialize
    super(nil, {}, 'text/html')
  end
  def run_test page
    page.visit '/builds/web/index.html'
    sleep(1)
    sleep(0.1) while page.evaluate_script("document.getElementById('gamefic_controls').getAttribute('class').indexOf('working') != -1")
    page.fill_in 'command', with: 'test me'
    page.click_button 'gamefic_submit'
    sleep(0.1) while page.evaluate_script("document.getElementById('gamefic_controls').getAttribute('class').indexOf('working') != -1")
  end
end

Capybara.app = TestFileServer.new
