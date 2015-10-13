require 'gamefic/director/order'

module Gamefic
  module Director
  
    module Parser
      def self.from_tokens(actor, tokens)
          options = []
          command = tokens.shift
          actions = actor.plot.actions_with_verb(command.to_sym)
          actions.each { |action|
            if action.queries.length == tokens.length
              valid = true
              index = 0
              action.queries.each { |query|
                if query.validate(actor, tokens[index]) == false
                  valid = false
                  break
                end
                index += 1
              }
              if valid
                arguments = []
                tokens.each { |token|
                    arguments.push [token]
                }
                options.push Order.new(actor, action, arguments)
              end
            end
          }
          if options.length == 0
            tokens.unshift command
          end
          options
      end
      def self.from_string(actor, command)
        # If we use Query::Base.new in the @disambiguator declaration, Opal
        # passes the block to the query instead of the action.
        #base = Query::Base.new
        #@disambiguator = Meta.new nil, nil, base do |actor, entities|
        #  definites = []
        #  entities.each { |entity|
        #    definites.push entity.definitely
        #  }
        #  actor.tell "I don't know which you mean: #{definites.join_or}."
        #end
        options = []
        if command.to_s == ''
          return options
        end
        matches = Syntax.match(command, actor.plot.syntaxes)
        matches.each { |match|
          actions = actor.plot.actions_with_verb(match.verb)
          actions.each { |action|
            options.concat bind_contexts_in_result(actor, match.arguments, action)
          }
        }
        options
      end
      private
      def self.bind_contexts_in_result(actor, handler, action)
        queries = action.queries.clone
        objects = self.execute_query(actor, handler.clone, queries, action)
        num_nil = 0
        while objects.length == 0 and queries.last.optional?
          num_nil +=1
          queries.pop
          objects = self.execute_query(actor, handler.clone, queries, action, num_nil)
        end
        return objects
      end
      def self.execute_query(actor, arguments, queries, action, num_nil = 0)
        # If the action verb is nil, treat the first argument as a query
        arguments.shift unless action.verb.nil?
        prepared = Array.new
        objects = Array.new
        valid = true
        last_remainder = nil
        queries.clone.each { |context|
          arg = arguments.shift || last_remainder
          if arg.nil? or arg == ''
            valid = false
            next
          end
          if context == String
            prepared.push [arg]
          elsif context.kind_of?(Query::Base)
            result = context.execute(actor, arg)
            if result.objects.length == 0
              valid = false
              next
            else
              prepared.push result.objects
              last_remainder = result.remainder
            end
          else
            raise TypeError.new("Action parameters must inherit from Query::Base")
          end
        }
        if valid == true
          prepared.each { |p|
            p.uniq!
          }
          num_nil.times do
            prepared.push [nil]
          end
          objects.push Order.new(actor, action, prepared)
        end
        objects
      end
    end

  end
end
