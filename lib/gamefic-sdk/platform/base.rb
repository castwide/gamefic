require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'

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
    def plot
      if @plot.nil?
        @plot = Gamefic::Sdk::Debug::Plot.new
        plot_config = YAML.load(File.read(source_dir + '/config.yaml'))
        @plot.source.directories.concat plot_config['sources']['script_paths']
        @plot.source.directories.push Gamefic::Sdk::GLOBAL_SCRIPT_PATH
        @plot.load "#{source_dir}/main.plot"
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
  end
end
