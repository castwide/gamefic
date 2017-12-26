require 'gamefic'
require 'gamefic-sdk/platform'
require 'gamefic-sdk/version'

module Gamefic::Sdk
  autoload :Server, 'gamefic-sdk/server'
  autoload :Config, 'gamefic-sdk/config'
  autoload :Binder, 'gamefic-sdk/binder'
  autoload :DebugPlot, 'gamefic-sdk/debug_plot'
  autoload :Diagram, 'gamefic-sdk/diagram'

  GLOBAL_SCRIPT_PATH = File.realpath(File.dirname(__FILE__) + "/../scripts/")
  PLATFORMS_PATH = File.realpath(File.dirname(__FILE__) + "/../platforms")
  LIB_PATH = File.dirname(__FILE__)
end
