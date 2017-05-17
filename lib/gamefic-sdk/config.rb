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

      def title
        @title ||= (data['title'] || 'Untitled')
      end

      def author
        @author ||= (data['author'] || 'Anonymous')
      end

      def script_paths
        @script_paths ||= (data['script_paths'] || ['./scripts', './imports']).map{ |p| Pathname.new(source_dir).join(p).to_s }
      end

      def import_paths
        @import_paths ||= (data['import_paths'] || [])
      end

      def media_paths
        @media_paths ||= (data['media_paths'] || ['./media']).map{ |p| Pathname.new(source_dir).join(p).to_s }
      end

      def build_path
        @build_path ||= Pathname.new(source_dir).join(data['build_path'] || './build')
      end

      def release_path
        @release_path ||= Pathname.new(source_dir).join(data['release_path'] || './release')
      end

      def auto_import?
        @auto_import ||= (data['auto_import'] || true)
      end

      def targets
        @targets ||= (data['targets'] || {})
      end

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
        config_file = File.join(directory, 'config.yaml')
        if File.exist?(config_file)
          config = YAML.load(File.read(config_file))
        else
          config = {}
        end
        Config.new(directory, config)
      end
    end
  end
end
