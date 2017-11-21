module Gamefic
  module Sdk
    class Shell
      module Plotter
        private

        # @return [Gamefic::Plot]
        def load_project directory
          config = Gamefic::Sdk::Config.load(directory)
          if config.auto_import?
            puts "Importing scripts..."
            Shell.start ['import', directory, '--quiet']
          end
          paths = [config.script_path, config.import_path] + Gamefic::Sdk.script_paths
          plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
          plot.script 'main'
          plot
        end
      end
    end
  end
end