# frozen_string_literal: true

module Gamefic
  module Filter
    def initialize subject, scope
      # The subject can either be an entity or a string.
      # Entity: the scope is rules for traversing around it.
      # String: the scope is just another string or a regexp
    end

    def matches
    end
  end
end
