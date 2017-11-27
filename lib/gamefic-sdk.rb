require 'gamefic'
require 'gamefic-sdk/platform'
require 'gamefic-sdk/debug'
require 'gamefic-sdk/version'

module Gamefic::Sdk
  autoload :Server, 'gamefic-sdk/server'
  autoload :Config, 'gamefic-sdk/config'
  autoload :Binder, 'gamefic-sdk/binder'

  GLOBAL_SCRIPT_PATH = File.realpath(File.dirname(__FILE__) + "/../scripts/")
  PLATFORMS_PATH = File.realpath(File.dirname(__FILE__) + "/../platforms")
  LIB_PATH = File.dirname(__FILE__)
end

class Class
  def descendants
    result = []
    ObjectSpace.each_object(::Class) {|klass| result << klass if klass < self }
    result
  end
end

class Gamefic::Entity
  def self.names
    result = []
    Entity.descendants.each { |e| result << e.to_s.split('::').last }
    result
  end
end
