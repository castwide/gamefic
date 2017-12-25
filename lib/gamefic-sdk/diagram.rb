require 'json'

module Gamefic
  module Sdk
    class Diagram
      class Position
        attr_accessor :x, :y

        def initialize x = 0, y = 0
          @x = x
          @y = y
          freeze
        end

        def move x, y
          Position.new(self.x + x, self.y + y)
        end
      end

      # @return [Gamefic::Plot]
      attr_reader :plot

      def initialize plot
        @plot = plot
      end

      def verbs
        plot.verbs
      end

      def rooms
        clear
        position = Position.new
        plot.entities.that_are(Room).each do |room|
          proceed_from room, position
          next_x = right
          next_y = bottom
          if next_x > next_y
            position = Position.new(0, next_y + distance)
          else
            position = Position.new(next_x + distance, 0)
          end
        end
        elements
      end

      private

      def distance
        150
      end

      def elements
        @elements ||= {}
      end

      def entity_uid entity
        raise "Invalid entity" if plot.entities.index(entity).nil?
        "EIN_#{plot.entities.index(entity)}"
      end

      def proceed_from room, position
        return if elements.has_key?(room)
        directions = ['north', 'south', 'west', 'east', 'northwest', 'northeast', 'southwest', 'southeast']
        rel = { data: {} }
        rel[:data][:id] = entity_uid(room)
        rel[:data][:label] = room.definitely
        rel[:position] = { x: position.x, y: position.y }
        elements[room] = rel
        room.children.that_are(Portal).each do |portal|
          next if portal.destination.nil?
          # For lack of a better way to lay them out, 'up' and 'down' are not
          # treated as specific directions
          if portal.direction.nil? or portal.direction.to_s == 'up' or portal.direction.to_s == 'down'
            direction = directions.shift
            new_pos = move_from(position, direction)
            while position_taken?(new_pos)
              direction = directions.shift
              return if direction.nil?
              new_pos = move_from(position, direction)
            end
          else
            directions.delete portal.direction.to_s
            new_pos = move_from(position, portal.direction.to_s)
          end
          proceed_from portal.destination, new_pos
          pel = { data: {} }
          pel[:data][:id] = entity_uid(portal)
          pel[:data][:source] = entity_uid(room)
          pel[:data][:target] = entity_uid(portal.destination)
          elements[portal] = pel
        end
      end

      def clear
        elements.clear
      end

      def bottom
        max_y = 0
        elements.values.each do |el|
          next if el[:position].nil?
          max_y = [max_y, el[:position][:y]].max
        end
        max_y
      end

      def right
        max_x = 0
        elements.values.each do |el|
          next if el[:position].nil?
          max_x = [max_x, el[:position][:x]].max
        end
        max_x
      end

      def position_taken?(position)
        elements.values.each do |el|
          next if el[:position].nil?
          return true if el[:position][:x] == position.x and el[:position][:y] == position.y
        end
        false
      end

      def move_from position, direction
        case direction
        when 'north'
          position.move 0, -distance
        when 'south'
          position.move 0, distance
        when 'west'
          position.move -distance, 0
        when 'east'
          position.move distance, 0
        when 'northwest'
          position.move -distance * 0.5, -distance * 0.5
        when 'northeast'
          position.move distance * 0.5, -distance * 0.5
        when 'southwest'
          position.move -distance * 0.5, distance * 0.5
        when 'southeast'
          position.move distance * 0.5, distance * 0.5
        end
      end
    end
  end
end
