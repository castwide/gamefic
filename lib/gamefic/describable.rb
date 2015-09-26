require "gamefic/keywords"

module Gamefic

  module Describable
    attr_reader :name
    attr_accessor :synonyms, :indefinite_article
    attr_writer :definite_article
    def keywords
      Keywords.new "#{name} #{synonyms}"
    end
    def indefinitely
      ((proper_named? or indefinite_article == '') ? '' : "#{indefinite_article} ") + name
    end
    def definitely
      ((proper_named? or definite_article == '') ? '' : "#{definite_article} ") + name
    end
    def definite_article
      @definite_article || "the"
    end
    def proper_named?
      (@proper_named == true)
    end
    def proper_named=(value)
      if value == true
        if @definite_article != nil
          @name = "#{@definite_article} #{@name}"
          @definite_article = nil
        end
      end
      @proper_named = value
    end
    def name=(value)
      # TODO: Split article from name
      words = value.split_words
      if ['a','an'].include?(words[0].downcase)
        @indefinite_article = words[0].downcase
        @definite_article = 'the'
        value = value[words[0].length+1..-1].strip
      else
        if words[0].downcase == 'the'
          if proper_named?
            @definite_article = nil
          else
            @definite_article = 'the'
            value = value[4..-1].strip
          end
        end
        # Try to guess the indefinite article
        if ['a','e','i','o','u'].include?(value[0,1].downcase)
          @indefinite_article = 'an'
        else
          @indefinite_article = 'a'
        end
      end
      @name = value
    end
    def has_description?
      (@description.to_s != '')
    end
    def description
      @description || (Describable.default_description % self.definitely)
    end
    def description=(value)
      @description = value
    end
    def self.default_description=(text)
      @default_description = text
    end
    def self.default_description
      @default_description || "There's nothing special about %s."
    end
    def to_s
      indefinitely
    end
  end
end
