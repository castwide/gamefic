require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'
require 'gamefic-sdk/plot_config'

module Gamefic::Sdk
  class Platform::Base
    # @return [Gamefic::Sdk::Debug::Plot]
    attr_reader :source_dir
    
    # @return [Hash]
    attr_reader :config
    
    def initialize source_dir, config = {}
      @source_dir = source_dir
      @config = defaults.merge(config)
      @config['target_dir'] ||= "release/#{config['name'] || self.class.to_s.split("::").last}"
      @config['build_dir'] ||= "build/#{config['name'] || self.class.to_s.split("::").last}"
      # Convert config directories into absolute paths
      @config['target_dir'] = File.absolute_path(@config['target_dir'], source_dir)
      @config['build_dir'] = File.absolute_path(@config['build_dir'], source_dir)
    end
    
    # @return [PlotConfig]
    def plot_config
      @plot_config ||= PlotConfig.new("#{source_dir}/config.yaml")
    end
    
    def plot
      if @plot.nil?
        paths = plot_config.script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        @plot = Gamefic::Sdk::Debug::Plot.new(Gamefic::Source::File.new(*paths))
        @plot.script 'main'
      end
      @plot
    end
    
    # Get a hash of default configuration values.
    # Platforms can overload this method to define their own defaults.
    # @return [Hash]
    def defaults
      @defaults ||= Hash.new
    end
    
    def build
      # Platforms need to build/compile the deployment here.
      raise "The base Platform class does not have a build method"
    end
    
    def clean
      puts "Nothing to do for this platform."
    end
    
    # Get a string of build metadata, represented as a hash.
    #
    # @return [Hash]
    def metadata
      hash = {}
      uuid = File.exist?(source_dir + '/.uuid') ? File.read(source_dir + '/.uuid').strip : ''
      hash[:uuid] = "#{uuid}"
      hash[:gamefic_version] = "#{Gamefic::VERSION}"
      hash[:sdk_version] = "#{Gamefic::Sdk::VERSION}"
      hash[:build_data] = "#{DateTime.now}"
      hash
    end
  end
end
