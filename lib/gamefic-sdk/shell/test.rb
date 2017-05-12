require 'gamefic-sdk/plot_config'
require 'gamefic/engine/tty'

module Gamefic
  module Sdk
    class Shell
      class Test
        def initialize(directory:)
          @path = directory
          raise "Invalid path: #{@path}" unless File.exist?(@path)
          puts "Loading..."
        end

        def run
          paths = config_path.script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
          plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
          plot.script 'main'
          # @todo Debug is temporarily disabled.
          #plot.script 'debug'
          engine = Engine::Tty.new plot
          engine.connect
          puts "\n"
          engine.run
        end

        private

        def config_path
          if File.directory?(@path)
            PlotConfig.new File.join(@path, 'config.yaml')
          else
            PlotConfig.new
          end
        end
      end
    end
  end
end
