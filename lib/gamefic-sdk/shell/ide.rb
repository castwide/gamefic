module Gamefic
  module Sdk
    class Shell
      class Ide < Thor
        include Gamefic::Sdk::Shell::Plotter

        desc 'verbs', 'Get a list of available verbs'
        def verbs
          plot = load_project '.'
          puts plot.verbs.to_json
        end
      end
    end
  end
end
