require 'gamefic'
require 'gamefic-sdk/platform'
#require 'gamefic-sdk/plot_config'
require 'gamefic-sdk/debug'
require 'gamefic-sdk/version'

module Gamefic::Sdk
  autoload :Server, 'gamefic-sdk/server'

  HTML_TEMPLATE_PATH = File.realpath(File.dirname(__FILE__) + "/../html/")
  GLOBAL_SCRIPT_PATH = File.realpath(File.dirname(__FILE__) + "/../scripts/")
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
