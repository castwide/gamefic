module Gamefic
	module Narrative
		def self.action command, *arguments, &proc
			
		end
		def self.get_binding(game)
			return binding
		end
		def self.method_missing(symbol, arguments)
			if Gamefic.const_defined?(symbol.to_s.cap_first)
				cls = Gamefic.const_get(symbol.to_s.cap_first)
				if cls.respond_to?(:create)
					cls.create(arguments)
				end
			else
				raise "Unrecognized method '#{symbol}'"
			end
		end
	end
end
