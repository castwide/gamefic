require 'gamefic/engine/tty'

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
          if config.auto_import?
            puts "Importing scripts..."
            Shell.start ['import', @path, '--quiet']
          end
          paths = [config.script_path, config.import_path, Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
          plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
          plot.script 'main'
          # @todo Debug is temporarily disabled.
          #plot.script 'debug'
          engine = Engine::Tty.new plot
          engine.connect
          puts "\n"
          engine.run
        end
      end
    end
  end
end
