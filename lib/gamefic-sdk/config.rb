require 'yaml'
require 'pathname'

module Gamefic
  module Sdk
    class Config
      attr_reader :source_dir
      attr_reader :data

      def initialize directory, data = {}
        @source_dir = directory
        @data = data

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
        @build_path ||= Pathname.new(source_dir).join(data['build_path'] || './build').to_s
      end

      # The absolute path to the project's release directory.
      #
      # @return [String]
      def release_path
        @release_path ||= Pathname.new(source_dir).join(data['release_path'] || './release').to_s
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

      # @return [Gamefic::Sdk::Config]
      def self.load directory
        config = {}
        ['config.yml', 'config.yaml'].each do |cy|
          config_file = File.join(directory, cy)
          if File.exist?(config_file)
            config = YAML.load(File.read(config_file))
            break
          end
        end
        Config.new(directory, config)
      end

      def self.generate author = 'Anonymous', title = 'Untitled'
<<-EOS
title: #{title}
author: #{author}

script_path: ./scripts
import_path: ./imports
media_path: ./media

build_path: ./build
release_path: ./release

targets:
  web:
    platform: Web
    html: ./html
  gfic:
    platform: Gfic
    filename: game.gfic
EOS
      end
    end
  end
end
