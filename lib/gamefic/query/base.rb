module Gamefic::Query
  class Base
    # Include is necessary here due to a strange namespace
    # resolution bug when interpreting gfic files
    include Gamefic
    @@last_new = nil
    attr_accessor :arguments
    def self.last_new
      @@last_new
    end
    def initialize *arguments
      test_arguments arguments
      @optional = false
      if arguments.include?(:optional)
        @optional = true
        arguments.delete :optional
      end
      @arguments = arguments
      @@last_new = self
      @match_hash = Hash.new
    end
    def allow_many?
      false
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
      arr = context_from(subject)
      @arguments.each { |arg|
        arr = arr.that_are(arg)
      }
      return arr.include?(object)
    end
    # @return [Array]
    def execute(subject, description)
      if allow_many? and !description.include?(',') and !description.include?(' and ')
        return Matches.new([], '', description)
      end
      array = context_from(subject)
      matches = Query.match(description, array)
      objects = matches.objects
      matches = Matches.new(objects, matches.matching_text, matches.remainder)
      if objects.length == 0 and matches.remainder == "it" and subject.respond_to?(:last_object)
        if !subject.last_object.nil?
          obj = subject.last_object
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
        }
        if allow_many?
          # HACK Ridiculously high magic number to force queries that return
          # arrays to take precedence over everything
          @specificity = @specificity * 100000
        end
      end
      @specificity
    end
    def signature
      return "#{self.class}(#{@arguments.join(',')})"
    end
    def test_arguments arguments
      cur_class = Gamefic::Entity
      cur_object = nil
      arguments.each { |a|
        if a.kind_of?(Class) or a.kind_of?(Module)
          cur_class = a
        elsif a.kind_of?(cur_class)
          cur_object = a
        elsif a.kind_of?(Symbol)
          if !cur_object.nil?
            if !cur_object.respond_to?(a)
              raise ArgumentError.new("Query signature target does not respond to #{a}")
            end
          else
            if !cur_class.instance_methods.include?(a)
              raise ArgumentError.new("Query signature target methods do not include #{a}")
            end
          end
        else
          raise ArgumentError.new("What the heck is this?")
        end
      }
    end
  end
end
