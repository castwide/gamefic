require 'gamefic/grammar'

module Gamefic

  # Add a variety of text properties for naming, describing, and referencing
  # objects.
  module Describable
    include Grammar::Person, Grammar::Plural
    include Matchable

    # Get the name of the object.
    # The name is usually presented without articles (e.g., "object" instead
    # of "an object" or "the object" unless the article is part of a proper
    # name (e.g., "The Ohio State University").
    #
    # @return [String]
    attr_reader :name

    # Alternate words that can be used to describe the object. Synonyms are
    # used in conjunction with the object's name when generating keywords.
    #
    # @return [String]
    attr_reader :synonyms

    # The object's indefinite article (usually "a" or "an").
    #
    # @return [String]
    attr_reader :indefinite_article

    # The object's definite article (usually "the").
    #
    # @return [String]
    attr_reader :definite_article

    # Get a set of keywords associated with the object.
    # Keywords are typically the words in the object's name plus its synonyms.
    #
    # @return [Keywords]
    def keywords
      @keywords ||= "#{definite_article} #{indefinite_article} #{name} #{synonyms}".downcase.split(Matchable::SPLIT_REGEXP).uniq
    end

    # Get the name of the object with an indefinite article.
    # Note: proper-named objects never append an article, though an article
    # may be included in its proper name.
    #
    # @return [String]
    def indefinitely
      ((proper_named? or indefinite_article == '') ? '' : "#{indefinite_article} ") + name.to_s
    end

    # Get the name of the object with a definite article.
    # Note: proper-named objects never append an article, though an article
    # may be included in its proper name.
    #
    # @return [String]
    def definitely
      ((proper_named? or definite_article == '') ? '' : "#{definite_article} ") + name.to_s
    end

    # Get the definite article for this object (usually "the").
    #
    # @return [String]
    def definite_article
      @definite_article || "the"
    end

    # Set the definite article.
    #
    # @param [String] article
    def definite_article= article
      @keywords = nil
      @definite_article = article
    end

    # Set the indefinite article.
    #
    # @param [String] article
    def indefinite_article= article
      @keywords = nil
      @indefinite_article = article
    end

    # Is the object proper-named?
    # Proper-named objects typically do not add articles to their names when
    # referenced #definitely or #indefinitely, e.g., "Jane Doe" instead of
    # "a Jane Doe" or "the Jane Doe."
    #
    # @return [Boolean]
    def proper_named?
      (@proper_named == true)
    end

    # Set whether the object has a proper name.
    #
    # @param bool [Boolean]
    def proper_named=(bool)
      if bool == true
        if @definite_article != nil
          @name = "#{@definite_article} #{@name}"
          @definite_article = nil
        end
      end
      @proper_named = bool
    end

    # Set the name of the object.
    # Setting the name performs some magic to determine how to handle
    # articles ("an object" and "the object").
    #
    # @param value [String]
    def name=(value)
      @keywords = nil
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

    # Does the object have a description?
    #
    # @return [Boolean]
    def has_description?
      (@description.to_s != '')
    end

    # Get the object's description.
    #
    # @return [String]
    def description
      @description || (Describable.default_description % { :name => self.definitely, :Name => self.definitely.capitalize_first })
    end

    # Set the object's description.
    #
    # @param text [String]
    def description=(text)
      if text != (Describable.default_description % { :name => self.definitely, :Name => self.definitely.capitalize_first })
        @description = text
      else
        @description = nil
      end
    end

    def synonyms= text
      @keywords = nil
      @synonyms = text
    end

    # Set the object's default description.
    # The default description is typically set in an object's initialization
    # to ensure that a non-empty string is available when a instance-specific
    # description is not provided
    #
    # @param text [String]
    def self.default_description=(text)
      @default_description = text
    end

    # Get the object's default description.
    #
    # @return [String]
    def self.default_description
      @default_description || "There's nothing special about %{name}."
    end

    # Get a String representation of the object. By default, this is the
    # object's name with an indefinite article, e.g., "a person" or "a red
    # dog."
    #
    # @return [String]
    def to_s
      indefinitely
    end
  end
end
