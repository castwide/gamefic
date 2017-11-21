require 'gamefic'
require 'gamefic-sdk/platform'
require 'gamefic-sdk/debug'
require 'gamefic-sdk/version'

module Gamefic::Sdk
  autoload :Server, 'gamefic-sdk/server'
  autoload :Config, 'gamefic-sdk/config'

  HTML_TEMPLATE_PATH = File.realpath(File.dirname(__FILE__) + "/../html/")
  GLOBAL_SCRIPT_PATH = File.realpath(File.dirname(__FILE__) + "/../scripts/")
  LIB_PATH = File.dirname(__FILE__)

  @@script_paths = []

  def self.mount path
    @@script_paths.push path
  end

  def self.script_paths
    @@script_paths
  end

  def self.script_paths_include? path
    @@script_paths.each do |p|
      return true if path.start_with?(p)
    end
    false
  end
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
