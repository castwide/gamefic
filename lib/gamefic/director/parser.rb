require 'gamefic/director/order'

module Gamefic
  module Director
  
    module Parser
      def self.from_tokens(plot, actor, tokens)
        options = []
        verb = tokens.shift
        actions = plot.actions_for(verb.to_sym)
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
        options.sort{ |a,b| b.action.specificity <=> a.action.specificity }
      end
      def self.from_string(plot, actor, command)
        options = []
        if command.to_s == ''
          return options
        end
        matches = Syntax.tokenize(command, plot.syntaxes)
        matches.each { |match|
          actions = plot.actions_for(match.verb)
          actions.each { |action|
            options.concat bind_contexts_in_result(actor, match.arguments, action)
          }
        }
        options.sort{ |a,b| b.action.specificity <=> a.action.specificity }
      end
      class << self
        private
        def bind_contexts_in_result(actor, handler, action)
          queries = action.queries.clone
          objects = execute_query(actor, handler.clone, queries, action)
          num_nil = 0
          while objects.length == 0 and queries.last.optional?
            num_nil +=1
            queries.pop
            objects = execute_query(actor, handler.clone, queries, action, num_nil)
          end
          return objects
        end
        def execute_query(actor, arguments, queries, action, num_nil = 0)
          # If the action verb is nil, treat the first argument as a query
          #arguments.shift unless action.verb.nil?
          prepared = Array.new
          objects = Array.new
          valid = true
          last_remainder = nil
          queries.clone.each { |context|
            arg = arguments.shift.to_s
            if last_remainder.to_s > ''
              arg = (last_remainder + " " + arg).strip
            end
            #if arg.nil? or arg == ''
            #  puts "Nil or empty arg?"
            #  valid = false
            #  next
            #end
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
            if last_remainder.nil? or last_remainder.empty?
              prepared.each { |p|
                p.uniq!
              }
              num_nil.times do
                prepared.push [nil]
              end
              objects.push Order.new(actor, action, prepared)
            else
              if !action.queries.last.allow_many? or action.queries.last.allow_ambiguous?
                misunderstood = Action.new nil, Query::Text.new do |actor, text|
                  actor.tell "I understand the first part of your command but not \"#{text}.\""
                end
                misunderstood.meta = true
                objects.push Order.new(actor, misunderstood, [[last_remainder]])
              end
            end
          end
          objects
        end
      end
    end

  end
end
