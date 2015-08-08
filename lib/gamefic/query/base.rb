module Gamefic::Query
  class Base
    @@last_new = nil
    attr_accessor :arguments
    def self.last_new
      @@last_new
    end
    def initialize *arguments
      @optional = false
      if arguments.include?(:optional)
        @optional = true
        arguments.delete :optional
      end
      @arguments = arguments
      @@last_new = self
      @match_hash = Hash.new
    end
    def last_match_for(subject)
      @match_hash[subject]
    end
    def optional?
      @optional
    end
    def context_from(subject)
      subject
    end
    def validate(subject, object)
      array = context_from(subject)
      @arguments.each { |arg|
        array = array.that_are(arg)
      }
      return array.include?(object)
    end
    def execute(subject, description)
      array = context_from(subject)
      matches = Query.match(description, array)
      objects = matches.objects
      @arguments.each { |arg|
        objects = objects.that_are(arg)
      }
      matches = Matches.new(objects, matches.matching_text, matches.remainder)
      if objects.length == 0 and matches.remainder == "it" and subject.respond_to?(:last_order)
        if !subject.last_order.nil? and !subject.last_order.arguments[0].nil?
          obj = subject.last_order.arguments[0]
          if validate(subject, obj)
            matches = Matches.new([obj], "it", "")
          end
        end
      end
      @match_hash[subject] = matches
      matches
    end
    def base_specificity
      0
    end
    def specificity
      if @specificity == nil
        @specificity = base_specificity
        magnitude = 1
        @arguments.each { |item|
        if item.kind_of?(Entity)
          @specificity += (magnitude * 10)
          item = item.class
        end
        if item.kind_of?(Class)
          s = item
          while s != nil
          @specificity += magnitude
          s = s.superclass
          end
        else
          @specificity += magnitude
        end
        #magnitude = magnitude * 10
        }
      end
      @specificity
    end
    def signature
      return "#{self.class}(#{@arguments.join(',')})"
    end
  end
end
