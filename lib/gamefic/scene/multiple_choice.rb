module Gamefic

  # Provide a list of options and process the selection in the scene's finish
  # block. After the scene is finished, the :active scene will be cued unless
  # some other scene has already been prepared or cued.
  #
  # The finish block's input parameter receives a MultipleChoice::Input object
  # instead of a String.
  #
  class Scene::MultipleChoice < Scene::Custom
    def data_class
      Scene::Data::MultipleChoice
    end

    def start actor
      data = start_data_for(actor)
      do_start_block actor, data
      tell_options actor, data
    end
    
    def finish actor, input
      data = finish_data_for(actor, input)
      get_choice data
      if data.selection.nil?
        actor.tell data.invalid_message
        tell_options actor, data
      else
        do_finish_block actor, data
      end
      data
    end

    private
    
    def get_choice data
      if data.input.strip =~ /[0-9]+/ and data.input.to_i > 0
        data.number = data.input.to_i
        data.index = data.number - 1
        data.selection = data.options[data.number - 1]
      else
        index = 0
        data.options.each { |o|
          if o.casecmp(data.input).zero?
            data.selection = o
            data.index = index
            data.number = index + 1
            break
          end
          index += 1
        }
      end
    end

    def tell_options actor, data
      list = '<ol class="multiple_choice">'
      data.options.each { |o|
        list += "<li>#{o}</li>"
      }
      list += "</ol>"
      actor.tell list
    end
    
  end

end
