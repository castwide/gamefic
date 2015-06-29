module Gamefic

  module Plot::CommandMount
    def meta(command, *queries, &proc)
      act = Meta.new(self, command, *queries, &proc)
    end
    def action(command, *queries, &proc)
      act = Action.new(self, command, *queries, &proc)
    end
    def respond(command, *queries, &proc)
      self.action(command, *queries, &proc)
    end
    def interpret(*args)
      xlate *args
    end
    def syntax(*args)
      xlate *args
    end
    def xlate(*args)
      syn = Syntax.new(self, *args)
      syn
    end
    def commandwords
      words = Array.new
      syntaxes.each { |s|
        word = s.first_word
        words.push(word) if !word.nil?
      }
      words.uniq
    end
  end
  
end
