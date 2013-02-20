require "lib/node"
require "lib/describable"

module Gamefic

	class Zone
		include Branch
		include Describable
		def initialize(args = {})
			args.each { |key, value|
				send "#{key}=", value
			}
		end
	end

end
