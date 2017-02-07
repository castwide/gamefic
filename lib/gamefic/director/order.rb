module Gamefic
  class Director::Order
    attr_reader :actor, :action, :arguments
    def initialize(actor, action, arguments)
      @actor = actor
      @action = action
      @arguments = arguments
      @canceled = false
    end
    def cancel
      @canceled = true
    end
    def canceled?
      @canceled
    end
  end
end
