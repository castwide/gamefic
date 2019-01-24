module Gamefic
  # A collection of scripts that can be included in a plot. 
  #
  class Structure
    def blocks
      @blocks ||= []
    end

    def script &block
      blocks.push block
    end
  end

  # A common Structure that gets included in plots by default.
  #
  BASE = Structure.new

  # Add a script to the Gamefic::BASE structure. These scripts get included in
  # plots by default.
  #
  def self.script &block
    BASE.script &block
  end
end
