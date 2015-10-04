require 'gamefic/grammar'

module Gamefic::Grammar
  module Person
    attr_writer :person
    def person
      @person ||= 3
    end
  end
end
