require 'gamefic/grammar'

module Gamefic::Grammar
  module Plural
    attr_writer :plural

    # Determine if the object is plural, e.g., "things" vs. "thing"
    #
    # @return [Boolean]
    def plural?
      if @plural.nil?
        @plural = false
      end
      @plural
    end
  end
end
