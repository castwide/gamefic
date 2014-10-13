module Gamefic::Sdk

  module Build
    def self.load filename = nil
      if !filename.nil?
        eval File.read(filename), nil, filename, 1
      else
        Configuration.new
      end
      Configuration.current
    end
    class Configuration
      attr_reader :import_paths
      attr_reader :html_paths
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
