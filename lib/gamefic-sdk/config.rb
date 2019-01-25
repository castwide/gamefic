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
      def initialize directory, data = Config.defaults
        @source_dir = File.absolute_path(directory)
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

      # The absolute path to the project's media directory.
      #
      # @return [String]
      def media_path
        @media_path ||= File.absolute_path(Pathname.new(source_dir).join(data['media_path'] || './media').to_s)
      end

      # The absolute path to the project's root directory.
      #
      # @return [String]
      def root_path
        @root_path ||= File.absolute_path(source_dir)
      end

      # The absolute path to the project's lib directory.
      #
      # @return [String]
      def lib_path
        @lib_path ||= File.absolute_path(Pathname.new(source_dir).join(data['lib_path'] || './lib').to_s)
      end

      # The path that is required to initialize the plot.
      #
      # @return [String]
      def main
        data['main']
      end

      # The absolute path to the project's builds directory.
      #
      # @return [String]
      def build_path
        @build_path ||= File.absolute_path(Pathname.new(source_dir).join(data['build_path'] || './builds').to_s)
      end

      # The absolute path to the project's targets directory.
      #
      # @return [String]
      def target_path
        @target_path ||= File.absolute_path(Pathname.new(source_dir).join(data['target_path'] || './targets').to_s)
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

      # Save this configuration to a file.
      #
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

      # Generate a YAML string with a default configuration and the specified
      # title and author.
      #
      # @return [String]
      def self.generate title = 'Untitled', author = 'Anonymous'
        data = self.defaults
        data['title'] = title
        data['author'] = author
        YAML.dump data
      end

      # The default values for a new project configuration. Keys are
      # represented as strings for consistency with YAML.
      #
      # @return [Hash]
      def self.defaults
        @defaults ||= JSON.parse({
          title: 'Untitled',
          author: 'Anonymous',
          lib_path: './lib',
          main: 'main',
          media_path: './media',
          target_path: './targets',
          build_path: './builds',
          targets: {
            ruby: {
              platform: 'Ruby',
              filename: 'game'
            }
          }
        }.to_json)
      end
    end
  end
end
