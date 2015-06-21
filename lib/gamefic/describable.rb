require "gamefic/keywords"

module Gamefic

  module Describable
    attr_reader :name
    attr_accessor :synonyms, :indefinite_article
    attr_writer :definite_article
    def keywords
      Keywords.new "#{name} #{synonyms}"
    end
    def keywords=(value)
      @keywords = value
    end
    def indefinitely
      (proper_named? ? '' : "#{indefinite_article} ") + name
    end
    def definitely
      (proper_named? ? '' : "#{definite_article} ") + name
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
      @description.to_s != '' ? @description : default_description
    end
    def default_description
      "There's nothing special about #{definitely}."
    end
    def description=(value)
      @description = value
    end
    def to_s
      indefinitely
    end
  end

  module DescribableArticles
    def a(entity)
      entity.indefinitely
    end
    def an(entity)
      entity.indefinitely
    end
    def the(entity)
      entity.definitely
    end
    def A(entity)
      entity.indefinitely.cap_first
    end
    def An(entity)
      entity.indefinitely.cap_first
    end
    def The(entity)
      entity.definitely.cap_first
    end
  end

end
