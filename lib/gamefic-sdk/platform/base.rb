require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'

module Gamefic::Sdk
  class Platform::Base
    # @return [Gamefic::Sdk::Debug::Plot]
    attr_reader :plot
    # @return [Hash]
    attr_reader :config
    def initialize plot, config = {}
      @plot = plot
      @config = defaults.merge(config)
      @config['target_dir'] ||= "release/#{config['name'] || self.class.to_s.split("::").last}"
      @config['build_dir'] ||= "build/#{config['name'] || self.class.to_s.split("::").last}"
      # Convert config directories into absolute paths
      @config['target_dir'] = File.absolute_path(@config['target_dir'], plot.main_dir)
      @config['build_dir'] = File.absolute_path(@config['build_dir'], plot.main_dir)
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
    def clean source_dir, target_dir
      puts "Nothing to do for this platform."
    end
  end
end
