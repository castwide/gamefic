require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'
#require 'gamefic-sdk/plot_config'
require 'pathname'

module Gamefic::Sdk
  class Platform::Base
    # @return [Hash]
    attr_reader :config

    # @return [Hash]
    attr_reader :target

    #def initialize config, name = nil
    def initialize config: Gamefic::Sdk::Config.new, target: {}
      #@source_dir = source_dir
      #@name = name
      #@config = config
      #@config.freeze
      @config = config
      @target = target
    end

    def name
      @name ||= (target['name'] || self.class.to_s.split('::').last.downcase)
    end

    def build_target
      @build_target ||= File.join(config.build_path, name)
    end

    def release_target
      @release_target ||= File.join(config.release_path, name)
    end

    # @return [Gamefic::Plot]
    def plot
      if @plot.nil?
        paths = config.script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
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

    def clean
      puts "Nothing to do for this platform."
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
