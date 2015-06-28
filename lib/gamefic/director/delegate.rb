module Gamefic
  class Director
    class Delegate
      @@assertion_stack = Array.new
      @@delegation_stack = Array.new
      def initialize(actor, actions, asserts, finishes)
        @actor = actor
        @actions = actions
        @asserts = asserts
        @finishes = finishes
      end
      def execute
        if @actor.is?(:debugging)
          @actor.tell "[DEBUG] Performing action"
        end
        befores = []
        afters = []
        @actions.each { |action|
          if action[0].kind_of?(Meta)
            befores.push action
          else
            afters.push action
          end
        }
        @@delegation_stack.push befores
        has_befores = (befores.length > 0)
        handle befores
        @@delegation_stack.pop
        if afters.length == 0 or (has_befores and afters[0][0].command == nil)
          return
        end
        @@assertion_stack.push Hash.new
        # Assertion of action is assumed true unless an assertion rule explicitly
        # returns false
        result = true
        @asserts.each { |key, rule|
          this_result = rule.test(@actor, @actions[0][0].command)
          if this_result == false
            if @actor.is?(:debugging)
              @actor.tell "[DEBUG] Asserting #{key} - defined at #{rule.caller}) - FALSE"
            end
            result = false
          else
            if @actor.is?(:debugging)
              @actor.tell "[DEBUG] Asserting #{key} - defined at #{rule.caller}) - TRUE"
            end
          end
        }
        if result == false
          return
        end
        @@delegation_stack.push afters
        handle afters
        @@delegation_stack.pop
        @actor.plot.finishes.each { |key, rule|
          rule.call(@actor)
        }
      end
      def handle options
        if options.length > 0
          opt = options.shift
          if opt[1][0].is?(:debugging)
            opt[1][0].tell "[DEBUG] Executing #{opt[0].class}: #{opt[0].signature} - defined at #{opt[0].caller})"
          end
          if opt[1].length == 1
            opt[0].execute(opt[1][0])
            opt[1][0].object_of_pronoun = nil
          else
            if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
              opt[1][0].object_of_pronoun = opt[1][1]
            elsif opt[1][0].parent == opt[1][1]
              opt[1][0].object_of_pronoun = nil
            end
            opt[0].execute(opt[1])
          end
        end
      end
      def self.next_command
        return nil if @@delegation_stack.last.nil? or @@delegation_stack.last[0].length == 0
        return @@delegation_stack.last[0][0].command
      end
      def self.passthru
        if @@delegation_stack.last != nil
          if @@delegation_stack.last.length > 0
            opt = @@delegation_stack.last.shift
            if opt[1][0].is?(:debugging)
              opt[1][0].tell "[DEBUG] Executing #{opt[0].class}: #{opt[0].signature} - defined at #{opt[0].caller})"
            end
            if opt[1].length == 1
              opt[0].execute(opt[1][0])
              opt[1][0].object_of_pronoun = nil
            else
              if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
                opt[1][0].object_of_pronoun = opt[1][1]
              elsif opt[1][0].parent == opt[1][1]
                opt[1][0].object_of_pronoun = nil
              end
              opt[0].execute(opt[1])
            end
          end
        end
      end
    end
  end
end
