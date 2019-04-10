module Gamefic::Grammar
  module Person
    attr_writer :person

    # Supported values are 1 (me), 2 (you), and 3 (him/her/it).
    #
    # @return [Integer]
    def person
      @person ||= 3
    end
  end
end
