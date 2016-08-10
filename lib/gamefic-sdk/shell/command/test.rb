require 'gamefic/shell'
require 'gamefic-sdk/plot_config'
require 'gamefic/engine/tty'

module Gamefic
  module Sdk

		class Shell::Command::Test < Gamefic::Shell::Command::Base
		  def run input
		    result = parse input
		    puts "Loading..."
		    path = result.arguments[1]
		    if !File.exist?(path)
		      raise "Invalid path: #{path}"
		    end
		    build_file = nil
		    main_file = path
		    test_file = nil
		    if File.directory?(path)
		      config = PlotConfig.new File.join(path, 'config.yaml')
		    else
		      config = PlotConfig.new
		    end
		    paths = config.script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
		    plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
		    plot.script 'main'
		    plot.script 'debug'
		    engine = Tty::Engine.new plot
		    puts "\n"
		    engine.run
		  end  
		end
    
  end
end
