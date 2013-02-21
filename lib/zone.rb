require "lib/node"
require "lib/describable"

module Gamefic

	# An optional class for grouping entities.
	class Zone
		include Branch
		# TODO: In all likelihood, Zones don't need
		# properties. They just need the capabilities
		# of a node to provide easy transportability.
		#include Describable
		#def initialize(args = {})
		#	args.each { |key, value|
		#		send "#{key}=", value
		#	}
		#end
		def update
			# TODO: This is just a stub to keep story updates from failing.
		end
	end

end
