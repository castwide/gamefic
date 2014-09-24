module Gamefic

  class Direction
    attr_accessor :name, :adjective, :adverb, :reverse
    def initialize args = {}
      args.each { |key, value|
        send "#{key}=", value
      }
      if !reverse.nil?
        reverse.reverse = self
      end
      proper_named = true
    end
    def adjective
      @adjective || @name
    end
    def adverb
      @adverb || @name
    end
    def reverse=(dir)
      @reverse = dir
    end
    def synonyms
      "#{adjective} #{adverb}"
    end
    def to_s
      @name
    end
  end

  NORTH = Direction.new(:name => 'north', :adjective => 'northern')
  SOUTH = Direction.new(:name => 'south', :adjective => 'southern', :reverse => NORTH)
  WEST = Direction.new(:name => 'west', :adjective => 'western')
  EAST = Direction.new(:name => 'east', :adjective => 'eastern', :reverse => WEST)
  NORTHWEST = Direction.new(:name => 'northwest', :adjective => 'northwestern')
  SOUTHEAST = Direction.new(:name => 'southeast', :adjective => 'southeastern', :reverse => NORTHWEST)
  NORTHEAST = Direction.new(:name => 'northeast', :adjective => 'northeastern')
  SOUTHWEST = Direction.new(:name => 'southwest', :adjective => 'southwestern', :reverse => NORTHEAST)
  UP = Direction.new(:name => 'up', :adjective => 'upwards')
  DOWN = Direction.new(:name => 'down', :adjective => 'downwards', :reverse => UP)

end
