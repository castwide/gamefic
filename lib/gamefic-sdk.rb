require 'gamefic'
require 'gamefic-sdk/gfk'
require 'gamefic-sdk/platform'

module Gamefic::Sdk
  HTML_TEMPLATE_PATH = File.dirname(__FILE__) + "/../html/"
  GLOBAL_SCRIPT_PATH = File.dirname(__FILE__) + "/../scripts/"
  # @deprecated
  GLOBAL_IMPORT_PATH = GLOBAL_SCRIPT_PATH
  LIB_PATH = File.dirname(__FILE__)
end

class Class
  def descendants
    result = []
    ObjectSpace.each_object(::Class) {|klass| result << klass if klass < self }
    result
  end
end

class Entity
  def self.names
    result = []
    Entity.descendants.each { |e| result << e.to_s.split('::').last }
    result
  end
end
