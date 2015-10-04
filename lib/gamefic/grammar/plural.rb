require 'gamefic/grammar'

module Gamefic::Grammar
  module Plural
    attr_writer :plural
    def plural?
      if @plural.nil?
        @plural = false
      end
      @plural
    end
  end
end
