require "core/grammar.rb"
require "core/keywords.rb"
require "core/entity.rb"
require "core/context.rb"
require "core/action.rb"
require "core/parser.rb"
require "core/delegate.rb"
require "core/commands.rb"
require "core/narrative.rb"

Dir["core/features/*.rb"].each { |file|
	require file
}
Dir["core/entities/*.rb"].each { |file|
	require file
}

module Gamefic

	class Game
		def initialize
			@player = nil
			@start = nil
		end
		def load(filename)
			File.open(filename) do |file|
				eval(file.read, Gamefic::Narrative.get_binding(self), filename, 1)
			end
		end
		def turn(input)
			action = @player.perform(input)
		end
		def run(player)
			@player = player
			@running = true
			while @running == true
				print "\n[#{player.parent.name.cap_first}]> "
				turn(STDIN.gets)
			end	
		end
	end

end
