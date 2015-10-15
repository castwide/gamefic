require 'gamefic'

module Gamefic::Sdk::Debug
  class Plot < Gamefic::Plot
    attr_reader :main_dir
    def action(command, *queries, &proc)
      act = Action.new(self, command, *queries, &proc)
    end
    def load script
      super
      if @main_dir.nil?
        @main_dir = File.dirname(File.absolute_path(script))
      end
    end
  end
end
