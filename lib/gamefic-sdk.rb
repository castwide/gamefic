require 'gamefic'
require 'gamefic-sdk/gfk'
require 'gamefic-sdk/platform'

module Gamefic::Sdk
  HTML_TEMPLATE_PATH = File.dirname(__FILE__) + "/../html/"
  GLOBAL_IMPORT_PATH = File.dirname(__FILE__) + "/../import/"
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
