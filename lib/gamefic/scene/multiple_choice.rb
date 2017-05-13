module Gamefic

  # Provide a list of options and process the selection in the scene's finish
  # block. After the scene is finished, the :active scene will be cued unless
  # some other scene has already been prepared or cued.
  #
  # The finish block's input parameter receives a MultipleChoice::Input object
  # instead of a String.
  #
  class Scene::MultipleChoice < Scene::Custom
    attr_reader :index
    attr_reader :number
    attr_reader :selection
    attr_writer :invalid_message

    def post_initialize
      self.type = 'MultipleChoice'
      self.prompt = 'Enter a choice:'
    end

    #def start actor
    #  data = start_data_for(actor)
    #  data.clear
    #  do_start_block actor, data
    #  tell_options
    #end
    
    def start
      super
      #raise "MultipleChoice scene has zero options" if options.empty?
    end

    def finish
      #data = finish_data_for(actor, input)
      get_choice
      if selection.nil?
        actor.tell invalid_message
        tell_options
      else
        super
      end
    end

    def options
      @options ||= []
    end

    def invalid_message
      @invalid_message ||= 'That is not a valid choice.'
    end

    def state
      super.merge options: options
    end

    private

    def get_choice
      if input.strip =~ /^[0-9]+$/ and input.to_i > 0
        @number = input.to_i
        @index = number - 1
        @selection = options[index]
      else
        i = 0
        options.each { |o|
          if o.casecmp(input).zero?
            @selection = o
            @index = i
            @number = index + 1
            break
          end
          i += 1
        }
      end
    end

    def tell_options
      list = '<ol class="multiple_choice">'
      options.each { |o|
        list += "<li><a href=\"#\" rel=\"gamefic\" data-command=\"#{o}\">#{o}</a></li>"
      }
      list += "</ol>"
      actor.tell list
    end
    
  end

end
