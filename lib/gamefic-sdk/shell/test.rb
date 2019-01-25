require 'gamefic-tty'

module Gamefic
  module Sdk
    class Shell
      class Test
        def initialize(directory:)
          @path = directory
          raise "Invalid path: #{@path}" unless File.exist?(@path)
        end

        def run
          puts "Loading..."
          config = Gamefic::Sdk::Config.new(@path)
          $LOAD_PATH.unshift config.lib_path
          require 'main'
          plot = Gamefic::Plot.new
          engine = Gamefic::Tty::Engine.new plot
          engine.connect
          puts "\n"
          engine.run
        end
      end
    end
  end
end
