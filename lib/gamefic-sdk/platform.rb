module Gamefic::Sdk

  module Platform
    autoload :Base, 'gamefic-sdk/platform/base'
    autoload :Gfic, 'gamefic-sdk/platform/gfic'
    autoload :Web, 'gamefic-sdk/platform/web'
    autoload :Sinatra, 'gamefic-sdk/platform/sinatra'

    #def self.load directory, platform
    #  config_file = File.join(directory, 'config.yaml')
    #end

    def self.load config, name
      target = config.targets[name]
      raise ArgumentError.new("Config does not have a target '#{name}'") if target.nil?
      cls = Gamefic::Sdk::Platform.const_get(target['platform'])
      raise ArgumentError.new("Platform '#{target['platform']}' not found") if target.nil?
      cls.new(config: config, target: target.merge('name' => name))
    end
  end

end
