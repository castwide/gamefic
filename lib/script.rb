module Gamefic

	module Scriptable
		def load filename
			File.open(filename) do |file|
				eval(file.read, binding, filename, 1)
			end
		end
	end

end
