module Gamefic::Sdk

  module Platform
    autoload :Base, 'gamefic-sdk/platform/base'
  end

end

Dir[File.dirname(__FILE__) + "/platform/*.rb"].each { |platform|
  require_relative platform
}
