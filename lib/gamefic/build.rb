module Gamefic

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
      @@current = nil
      def initialize &block
        @import_paths = []
        @media_paths = []
        yield self if block_given?
        @@current = self
      end
      def self.current
        @@current || Configuration.new
      end
    end
  end

end
