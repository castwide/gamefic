module Gamefic::Sdk

  class Platform
    attr_reader :config
    def initialize args = {}
      @config = defaults.merge(args)
    end
    def defaults
      # Platforms can use this method to define the default configuration.
      @defaults ||= Hash.new
    end
    def build source_dir, target_dir, plot
      # Platforms need to build/compile the deployment here.
    end
  end

end

Dir[File.dirname(__FILE__) + "/platform/*.rb"].each { |platform|
  require_relative platform
}
