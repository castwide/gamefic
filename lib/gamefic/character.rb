module Gamefic
  class Character < Entity
    attr_reader :queue, :user
    # @return [Gamefic::Director::Order]
    attr_reader :last_order
    # @return [Entity,nil]
    attr_reader :last_object
    attr_accessor :object_of_pronoun, :scene
    
    def initialize(plot, args = {})
      @queue = Array.new
      super
      buffering = false
    end
    def connect(user)
      @user = user
    end
    def disconnect
      # TODO: We might need some cleanup here. Like, move the character out of the game, or set a timeout to allow dropped users to reconnect... figure it out.
      @user = nil
    end
    def perform(*command)
      Director.dispatch(self, *command)
    end
    def quietly(*command)
      if user.nil?
        perform *command
      else
        buffer = ""
        buffering = true
        perform *command
        buffering = false
        buffer
      end
    end
    def tell(message)
      if user != nil and message.to_s != ''
        if buffering
          buffer += message
        else
          message = "<p>#{message}</p>"
          # This method uses String#gsub instead of String#gsub! for
          # compatibility with Opal.
          message = message.gsub(/\n\n/, '</p><p>')
          message = message.gsub(/\n/, '<br/>')
          user.stream.send message
        end
      end
    end
    def stream(message)
      user.stream.send message
    end
    def destroy
      if @user != nil
        @user.quit
      end
      super
    end
    #def update
    #  puts "Character update"
    #  super
    #  if (line = queue.shift)
    #    @scene.finish self, line
    #  end
    #end
    def proceed
      return if delegate_stack.last.nil?
      delegate_stack.last.proceed
    end
    def on_turn
      
    end
    private
    attr_accessor :buffering, :buffer
    def delegate_stack
      @delegate_stack ||= []
    end
    def last_order=(order)
      @last_order = order
      if !order.action.kind_of?(Meta) and !order.arguments[0].nil? and !order.arguments[0][0].nil? and order.arguments[0][0].kind_of?(Entity)
        @last_object = order.arguments[0][0]
      end
    end
  end

end
