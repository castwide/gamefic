module Gamefic

	class Car < Entity
		include Itemized
	end

	class Waypoint < Room
		attr_writer :location
		def post_initialize
			car = Car.new :name => 'car', :longname => 'your car', :description => 'Enter DRIVE to select a location.'
			car.parent = self
		end
		def location
			@location.to_s != '' ? @location : longname
		end
		def synonyms
			"#{super} #{location}"
		end
	end

	class Character
		class Drive < State
			def flush
				# Don't flush?
			end
			def post_initialize
				@locations = Array.new
				@entity.root.flatten.that_are(Waypoint).each { |waypoint|
					@locations.push waypoint
				}
				if @locations.length > 0
					@entity.tell "# Select a location:"
					@locations.each_index { |i|
						@entity.tell "#{i + 1}. #{@locations[i].location}"
					}
				else
					@entity.tell "Nowhere to go."
					@entity.state = Ready
				end
			end
			def update
				command = @entity.queue.shift
				if command != nil
					i = command.to_i - 1
					if i >= 0
						location = @locations[i]
						if location != nil
							if @entity.parent == location
								@entity.tell "You're already there."
							else
								@entity.parent.children.that_are_not(@entity).each { |e|
									e.tell "#{@entity.longname} leaves in a car.", true
								}
								@entity.parent = location
								@entity.tell "You drive to #{location.location}."
								@entity.parent.children.that_are_not(@entity).each { |e|
									e.tell "#{@entity.longname} arrives in a car.", true
								}
								@entity.inject "itemize room"
							end
							@entity.state = Ready
						else
							@entity.tell "Invalid location."
						end
					else
						@entity.state = Ready
					end
				end
			end
		end
	end
	
end
