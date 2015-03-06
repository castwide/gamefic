module Gamefic::Sdk

  module Build
    def self.load filename = nil
      if !filename.nil?
        eval File.read(filename), nil, filename, 1
        directory = File.dirname(filename)
        Configuration.current.import_paths.each_index { |i|
          if Configuration.current.import_paths[i][0,1] != '/'
            Configuration.current.import_paths[i] = directory + '/' + Configuration.current.import_paths[i]
          end
        }
        Configuration.current.import_paths.unshift directory + '/import'
      else
        Configuration.new
      end
      Configuration.current.import_paths.push Gamefic::GLOBAL_IMPORT_PATH
      Configuration.current
    end
    def self.release plot, config
        directory = plot.game_directory
        if config.platforms.length > 0
          config.platforms.each_pair { |k, v|
            v.config[:title] = config.title
            v.config[:author] = config.author
            puts "Building release/#{k}..." #unless quiet
            platform_dir = "#{directory}/release/#{k}"
            v.build directory, platform_dir, plot
          }
          puts "Build#{config.platforms.length > 1 ? 's' : ''} complete." #unless quiet
        else
          puts "Build configuration does not have any target platforms."
        end
    end
    class Configuration
      attr_reader :import_paths, :html_paths
      attr_accessor :title, :author
      @@current = nil
      def initialize &block
        @import_paths = []
        @platforms = {}
        yield self if block_given?
        @@current = self
      end
      def platforms
        @platforms.clone
      end
      def target *args
        if args.length == 1
          platform = args.shift
          name = platform.class.to_s.split('::').last.downcase
        else
          name = args.shift
          platform = args.shift
        end
        if @platforms[name].nil?
          @platforms[name] = platform
        else
          raise "The '#{name}' platform already has a configuration"
        end
      end
      def platform name
        @platforms[name]
      end
      def self.current
        @@current || Configuration.new
      end
    end
  end

end
