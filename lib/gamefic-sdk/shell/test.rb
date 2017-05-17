#require 'gamefic-sdk/plot_config'
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
          paths = config.script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
          plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
          plot.script 'main'
          # @todo Debug is temporarily disabled.
          #plot.script 'debug'
          engine = Engine::Tty.new plot
          engine.connect
          puts "\n"
          engine.run
        end

        #private

        #def base_config
        #  if File.directory?(@path)
        #    Gamefic::Sdk::Platform::Base.new File.join(@path, 'config.yaml')
        #  else
        #    Gamefic::Sdk::Platform::Base.new
        #  end
        #end

      end
    end
  end
end
