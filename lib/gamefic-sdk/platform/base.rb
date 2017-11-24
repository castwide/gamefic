require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'
require 'pathname'

module Gamefic::Sdk
  class Platform::Base
    # @return [Gamefic::Sdk::Config]
    attr_reader :config

    # @return [Hash]
    attr_reader :target

    def initialize config: Gamefic::Sdk::Config.new, target: {}
      @config = config
      @target = target
    end

    def name
      @name ||= (target['name'] || self.class.to_s.split('::').last.downcase)
    end

    # The path to the build directory (the compiled game).
    #
    # @return [String]
    def build_dir
      @build_dir ||= File.join(config.build_path, name)
    end

    # The path to the target directory (the platform-specific code).
    #
    # @return [String]
    def target_dir
      @target_dir ||= File.join(config.target_path, name)
    end

    # @return [Gamefic::Plot]
    def plot
      if @plot.nil?
        paths = [config.script_path, config.import_path] + config.library_paths
        # @todo: Should really use Gamefic::Sdk::Debug::Plot or just Gamfic::Plot?
        @plot = Gamefic::Sdk::Debug::Plot.new(Gamefic::Source::File.new(*paths))
        @plot.script 'main'
      end
      @plot
    end

    def build
      # Platforms need to build/compile the deployment here.
      raise "The base Platform class does not have a build method"
    end

    def make_target
    end

    # Get a hash of build metadata.
    #
    # @return [Hash]
    def metadata
      hash = {}
      hash[:uuid] = config.uuid
      hash[:gamefic_version] = "#{Gamefic::VERSION}"
      hash[:sdk_version] = "#{Gamefic::Sdk::VERSION}"
      hash[:build_date] = "#{DateTime.now}"
      hash
    end
  end
end
