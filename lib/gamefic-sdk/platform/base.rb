require 'gamefic-sdk'
require 'gamefic-sdk/debug/plot'
#require 'gamefic-sdk/plot_config'
require 'pathname'

module Gamefic::Sdk
  class Platform::Base
    # @return [Gamefic::Sdk::Debug::Plot]
    attr_reader :source_dir

    # @return [String]
    attr_reader :name

    # @return [Hash]
    attr_reader :config

    def initialize source_dir, name, config = {}
      @source_dir = source_dir
      @name = name
      @config = config
      @config.freeze
    end

    # @return [Array<String>]
    def script_paths
      @script_paths ||= (config['script_paths'] || ['./scripts', './imports']).map{ |p| File.join(source_dir, p) }
    end

    # @return [Array<String>]
    def import_paths
      @import_paths ||= (config['import_paths'] || []).map{ |p| File.join(source_dir, p) }
    end

    # @return [Array<String>]
    def media_paths
      @media_paths ||= (config['media_paths'] || []).map{ |p| File.join(source_dir, p) }
    end

    # @return [String]
    def build_path
      @build_path ||= Pathname.new(source_dir).join((config['build_path'] || 'build'), name).to_s
    end

    # @return [String]
    def release_path
      @release_path ||= Pathname.new(source_dir).join((config['release_path'] || 'release'), name).to_s
    end

    # @return [Gamefic::Plot]
    def plot
      if @plot.nil?
        paths = script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        # @todo: Should really use Gamefic::Sdk::Debug::Plot or just Gamfic::Plot?
        @plot = Gamefic::Sdk::Debug::Plot.new(Gamefic::Source::File.new(*paths))
        @plot.script 'main'
      end
      @plot
    end
    
    # Get a hash of default configuration values.
    # Platforms can overload this method to define their own defaults.
    #
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
      hash[:build_date] = "#{DateTime.now}"
      hash
    end
  end
end
