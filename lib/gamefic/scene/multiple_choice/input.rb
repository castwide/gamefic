module Gamefic
  class Gamefic::Scene::MultipleChoice::Input
    attr_reader :raw, :number, :index, :choice
    def initialize raw, index, choice
      @raw = raw
      @index = index
      @number = index + 1
      @choice = choice
    end
  end
end
