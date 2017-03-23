module Gamefic::Sdk

  module Platform
    autoload :Base, 'gamefic-sdk/platform/base'
    autoload :Gfic, 'gamefic-sdk/platform/gfic'
    autoload :Web, 'gamefic-sdk/platform/web'
    autoload :Sinatra, 'gamefic-sdk/platform/sinatra'
  end

end
