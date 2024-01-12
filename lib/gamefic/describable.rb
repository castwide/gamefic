# frozen_string_literal: true

module Gamefic
  # A variety of text properties for naming, describing, and referencing
  # objects.
  #
  module Describable
    # The object's name.
    # Names are usually presented without articles (e.g., "object" instead
    # of "an object" or "the object") unless the article is part of a proper
    # name (e.g., "The Ohio State University").
    #
    # @return [String]
    attr_reader :name

    # Alternate words that can reference the object. Synonyms are used in
    # conjunction with the object's name when scanning tokens.
    #
    # @return [String]
    attr_reader :synonyms

    # The object's indefinite article (usually "a" or "an").
    #
    # @return [String]
    attr_accessor :indefinite_article

    # The object's definite article (usually "the").
    #
    # @return [String]
    attr_writer :definite_article

    def keywords
      "#{name} #{synonyms}".keywords
    end

    # The name of the object with an indefinite article.
    # Note: proper-named objects never append an article, though an article
    # may be included in its proper name.
    #
    # @return [String]
    def indefinitely
      (proper_named? || indefinite_article == '' ? '' : "#{indefinite_article} ") + name.to_s
    end

    # The name of the object with a definite article.
    # Note: proper-named objects never append an article, though an article
    # may be included in its proper name.
    #
    # @return [String]
    def definitely
      (proper_named? || definite_article == '' ? '' : "#{definite_article} ") + name.to_s
    end

    # Tefinite article for this object (usually "the").
    #
    # @return [String]
    def definite_article
      @definite_article || "the"
    end

    # Is the object proper-named?
    # Proper-named objects typically do not add articles to their names when
    # referenced #definitely or #indefinitely, e.g., "Jane Doe" instead of
    # "a Jane Doe" or "the Jane Doe."
    #
    # @return [Boolean]
    def proper_named?
      @proper_named == true
    end

    # Set whether the object has a proper name.
    #
    # @param bool [Boolean]
    def proper_named=(bool)
      if bool && @definite_article
        @name = "#{@definite_article} #{@name}".strip
        @definite_article = nil
      end
      @proper_named = bool
    end

    # Set the name of the object.
    # Setting the name performs some magic to determine how to handle
    # articles ("an object" and "the object").
    #
    # @param value [String]
    def name=(value)
      words = value.split
      if %w[a an].include?(words[0].downcase)
        @indefinite_article = words[0].downcase
        @definite_article = 'the'
        value = value[words[0].length + 1..].strip
      else
        if words[0].downcase == 'the'
          if proper_named?
            @definite_article = nil
          else
            @definite_article = 'the'
            value = value[4..].strip
          end
        end
        # Try to guess the indefinite article
        @indefinite_article = if %w[a e i o u].include?(value[0, 1].downcase)
                                'an'
                              else
                                'a'
                              end
      end
      @name = value
    end

    # Does the object have a description?
    #
    # @return [Boolean]
    def description?
      @description.to_s != ''
    end
    alias has_description? description?

    # Get the object's description.
    #
    # @return [String]
    def description
      @description || format(Describable.default_description, name: definitely, Name: definitely.capitalize_first)
    end

    # Set the object's description.
    #
    # @param text [String]
    def description=(text)
      @description = (text if text != (format(Describable.default_description, name: definitely, Name: definitely.capitalize_first)))
    end

    def synonyms= text
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
      @default_description || "There's nothing special about %<name>s."
    end

    # Get a String representation of the object. By default, this is either
    # the object's name with an indefinite article, e.g., "a person" or "a red
    # dog"; or its proper name, e.g., "Mr. Smith".
    #
    # @return [String]
    def to_s
      indefinitely
    end
  end
end
