module Gamefic

  class MultipleChoiceSceneManager < SceneManager
    def data_class
      MultipleChoiceSceneData
    end
    def scene_class
      MultipleChoiceScene
    end
    def state
      @state ||= "MultipleChoice"
    end
    def prompt
      @prompt ||= "Enter a choice:"
    end
  end
  
  class MultipleChoiceSceneData < SceneData
    attr_accessor :index, :selection, :options
    def options
      @options ||= []
    end
  end

  class MultipleChoiceScene < Scene
    def initialize manager, key
      super
      @prompt ||= "Enter a choice:"
    end
    def start actor
      super
      list = '<ol class="multiple_choice">'
      @data.options.each { |o|
        list += "<li>#{o}</li>"
      }
      list += "</ol>"
      actor.tell list
      @data.prompt ||= @prompt
    end
    def finish actor, input
      @data.input = input
      @data.index = nil
      @data.selection = nil
      if @data.input.strip =~ /[0-9]+/
        @data.index = input.to_i - 1
        @data.selection = @data.options[@data.index]
        @data.index = nil if @data.selection.nil?
      else
        i = 0
        @data.options.each { |o|
          if o.casecmp(@data.input).zero?
            @data.index = i
            @data.selection = o
            break
          end
          i += 1
        }
      end
      if @data.selection.nil?
        # TODO: Consider allowing for an error block to customize this
        # response.
        actor.tell "That's not a valid selection."
      else
        data.next_cue ||= :active
        if !@finish.nil?
          @finish.call actor, data
        end
      end
    end
  end

end
