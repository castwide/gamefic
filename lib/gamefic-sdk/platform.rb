module Gamefic::Sdk

  module Platform
    autoload :Base, 'gamefic-sdk/platform/base'
    autoload :Gfic, 'gamefic-sdk/platform/gfic'
    autoload :Web, 'gamefic-sdk/platform/web'
    autoload :Sinatra, 'gamefic-sdk/platform/sinatra'
    autoload :Ruby, 'gamefic-sdk/platform/ruby'
    autoload :OpalBuilder, 'gamefic-sdk/platform/opal_builder'
    autoload :Webpack, 'gamefic-sdk/platform/webpack'
    autoload :ReactApp, 'gamefic-sdk/platform/react_app'

    # Load a platform for the provided config and target name.
    # The target name must have an entry in the config's targets, and the
    # target's platform must reference a valid platform class name.
    #
    # @param config [Gamefic::Sdk::Config] The project config
    # @param name [String] The target name
    # @return [Gamefic::Sdk::Platform::Base]
    def self.load config, name
      target = config.targets[name]
      raise ArgumentError.new("Config does not have a target '#{name}'") if target.nil?
      cls = Gamefic::Sdk::Platform.const_get(target['platform'])
      raise ArgumentError.new("Platform '#{target['platform']}' not found") if target.nil?
      cls.new(config: config, target: target.merge('name' => name))
    end
  end

end
