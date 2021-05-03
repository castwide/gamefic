module Gamefic
  # Provide a list of options and process the selection in the scene's finish
  # block. After the scene is finished, the :active scene will be cued unless
  # some other scene has already been prepared or cued.
  #
  # The finish block's input parameter receives a MultipleChoice::Input object
  # instead of a String.
  #
  class Scene::MultipleChoice < Scene::Custom
    # The zero-based index of the selected option.
    #
    # @return [Integer]
    attr_reader :index

    # The one-based index of the selected option.
    #
    # @return [Integer]
    attr_reader :number

    # The full text of the selected option.
    #
    # @return [String]
    attr_reader :selection

    attr_writer :invalid_message

    def post_initialize
      self.type = 'MultipleChoice'
      self.prompt = 'Enter a choice:'
    end

    def finish
      get_choice
      if selection.nil?
        actor.tell invalid_message
      else
        super
      end
    end

    # The array of available options.
    #
    # @return [Array<String>]
    def options
      @options ||= []
    end

    # The text to display when an invalid selection is received.
    #
    # @return [String]
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
  end
end
