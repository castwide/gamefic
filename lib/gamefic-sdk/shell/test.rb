require 'gamefic-tty'

module Gamefic
  module Sdk
    class Shell
      class Test
        include Gamefic::Sdk::Shdell::Plotter

        def initialize(directory:)
          @path = directory
          raise "Invalid path: #{@path}" unless File.exist?(@path)
        end

        def run
          puts "Loading..."
          plot = load_project(@path)
          engine = Gamefic::Tty::Engine.new plot
          engine.connect
          puts "\n"
          engine.run
        end
      end
    end
  end
end
