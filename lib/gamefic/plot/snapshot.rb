require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      initial_state
      internal_save
    end

    def restore snapshot
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
      # @todo Move this stuff to the darkroom
      return
      entities[initial_state.length..-1].each do |e|
        destroy e
      end
      # @todo This line shouldn't be necessary. Detroying the entity should remove it
      # from the array. Besides, #entities returns a clone.
      #entities.slice! initial_state.length..-1
      i = 0
      snapshot[:entities].each { |h|
        if entities[i].nil?
          e = stage "make #{h[:class]}"
          STDERR.puts "Made a #{e.class}"
          entities.push e
        end
        rebuild1 entities[i], h
        i += 1
      }
      snapshot[:subplots].each { |sh|
        sp = stage "branch #{sh[:class]}"
        sp.introduce players
        sp.restore sh
      }
      i = 0
      snapshot[:entities].each { |h|
        rebuild2 entities[i], h
        i += 1
      }
      rebuild1 players[0], snapshot[:player]
      rebuild2 players[0], snapshot[:player]
      players[0].cue default_scene #if players[0].scene.nil? and players[0].next_scene.nil?
    end

    def initial_state
      if @initial_state.nil?
        @initial_state = internal_save
      end
      @initial_state
    end

    private

    def internal_save
      #h = { entities: [], subplots: [] }
      #subplots.each { |s|
      #  sh = hash_subplot s
      #  h[:subplots].push sh
      #}
      #entities.each { |e|
      #  h[:entities].push hash_entity(e)
      #}
      #h[:player] = hash_entity(players[0])
      #h[:class] = self.class
      #h
      Gamefic::Plot::Darkroom.new(self).save
    end
  end
end
