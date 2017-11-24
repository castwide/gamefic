require 'yaml'
require 'pathname'

module Gamefic
  module Sdk
    class Config
      attr_reader :source_dir
      attr_reader :data

      # Create a configuration for the project in the specified directory and
      # initialize settings from an optional hash.
      # Use Config.load(directory) to generate a configuration from the config
      # file in the directory's root.
      #
      def initialize directory, data = {}
        @source_dir = directory
        @data = data
        require_libraries

        @source_dir.freeze
        @data.freeze
      end

      # The game's title.
      #
      # @return [String]
      def title
        @title ||= (data['title'] || 'Untitled')
      end

      # The game's author.
      #
      # @return [String]
      def author
        @author ||= (data['author'] || 'Anonymous')
      end

      # The absolute path to the project's script directory.
      #
      # @return [String]
      def script_path
        @script_path ||= Pathname.new(source_dir).join(data['script_path'] || './scripts').to_s
      end

      # The absolute path to the project's import directory.
      #
      # @return [String]
      def import_path
        @import_paths ||= Pathname.new(source_dir).join(data['import_path'] || './imports').to_s
      end

      # The absolute path to the project's media directory.
      #
      # @return [String]
      def media_path
        @media_path ||= Pathname.new(source_dir).join(data['media_path'] || './media').to_s
      end

      # The absolute path to the project's build directory.
      #
      # @return [String]
      def build_path
        @build_path ||= Pathname.new(source_dir).join(data['build_path'] || './builds').to_s
      end

      def target_path
        @target_path ||= Pathname.new(source_dir).join(data['target_path'] || './targets').to_s
      end

      def libraries
        @libraries ||= data['libraries'] || []
      end

      def library_paths
        if @library_paths.nil?
          @library_paths = []
          libraries.each do |l|
            @library_paths.push Gamefic::Library.path(l)
          end
        end
        @library_paths
      end

      def auto_import?
        @auto_import ||= (data['auto_import'] || true)
      end

      # A hash of each target's name and its configuration options.
      #
      # @return [Hash]
      def targets
        @targets ||= (data['targets'] || {})
      end

      # A universal unique identifier for the project.
      #
      # @return [String]
      def uuid
        if @uuid.nil?
          if File.file?(File.join source_dir, '.uuid')
            @@uuid = File.read(File.join source_dir, '.uuid').strip
          end
        end
        @uuid
      end

      def render filename
        erb = ERB.new(File.read(filename))
        erb.result binding
      end

      def save filename = nil
        filename ||= File.join(source_dir, 'config.yml')
        # @todo Generate the YAML
        File.write filename, YAML.dump(data)
      end

      # Load a configuration from the specified directory.
      # This method requires a config.yml file to exist in the directory root.
      #
      # @return [Gamefic::Sdk::Config]
      def self.load directory, overrides = {}
        config = {}
        found = false
        ['config.yml', 'config.yaml'].each do |cy|
          config_file = File.join(directory, cy)
          if File.exist?(config_file)
            config = YAML.load(File.read(config_file))
            found = true
            break
          end
        end
        raise LoadError.new("Gamefic config file not found") if !found
        Config.new(directory, config.merge(overrides))
      end

      def self.generate author = 'Anonymous', title = 'Untitled'
<<-EOS
title: #{title}
author: #{author}

script_path: ./scripts
import_path: ./imports
media_path: ./media

libraries:
- standard

build_path: ./builds
target_path: ./targets

auto_import: true

targets:
  web:
    platform: Web
  ruby:
    platform: Ruby
    filename: game
EOS
      end

      private

      def require_libraries
        $LOAD_PATH.unshift File.join(source_dir, 'lib')
        libraries.each { |lib| require "gamefic-library-#{lib}" }
        $LOAD_PATH.shift
      end
    end
  end
end
