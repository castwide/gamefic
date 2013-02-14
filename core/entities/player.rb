module Gamefic

	class Player < Character
		def initialize
			super
			@story = Theater.instance
		end
		def story
			@story
		end
		def tell(message)
			if message.to_s != ''
				puts message.terminalize
			end
		end
		def cast(story)
			if @story != Theater.instance and story != nil
				tell "You're already playing a story."
			elsif story == nil
				@story = Theater.instance
			else
				@story = story
			end
		end
	end

end
