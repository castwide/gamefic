module Gamefic

  module Stage
    # Execute a block of code in a subset of the object's scope.
    #
    # An object's stage is an isolated namespace that has its own instance
    # variables and access to its container's public methods.
    def stage *args, &block
      s = generate_stage
      if block.nil?
        s.module_eval(*args)
      else
        s.module_exec(*args, &block)
      end
    end

    private

    def generate_stage
      return @stage unless @stage.nil?
      instance = self

      @stage = Module.new do
        define_singleton_method :method_missing do |symbol, *args, &block|
          m = instance.public_method(symbol)
          if m.nil?
            super
          else
            m.call(*args, &block) unless m.nil?
          end
        end
      end

      @stage
    end

  end

end
