class Direction
    attr_accessor :name, :adjective, :adverb, :reverse

    def initialize args = {}
      args.each { |key, value|
        send "#{key}=", value
      }
      if !reverse.nil?
        reverse.reverse = self
      end
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

    class << self
      def compass
        if @compass.nil?
          @compass = {}
          @compass[:north] = Direction.new(:name => 'north', :adjective => 'northern')
          @compass[:south] = Direction.new(:name => 'south', :adjective => 'southern', :reverse => @compass[:north])
          @compass[:west] = Direction.new(:name => 'west', :adjective => 'western')
          @compass[:east] = Direction.new(:name => 'east', :adjective => 'eastern', :reverse => @compass[:west])
          @compass[:northwest] = Direction.new(:name => 'northwest', :adjective => 'northwestern')
          @compass[:southeast] = Direction.new(:name => 'southeast', :adjective => 'southeastern', :reverse => @compass[:northwest])
          @compass[:northeast] = Direction.new(:name => 'northeast', :adjective => 'northeastern')
          @compass[:southwest] = Direction.new(:name => 'southwest', :adjective => 'southwestern', :reverse => @compass[:northeast])
          @compass[:up] = Direction.new(:name => 'up', :adjective => 'upwards')
          @compass[:down] = Direction.new(:name => 'down', :adjective => 'downwards', :reverse => @compass[:up])
        end
        @compass
      end

      def find(dir)
        compass[dir.to_s.downcase.to_sym]
      end
    end
end
