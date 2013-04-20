require "gamefic/keywords"

module Gamefic

	module Describable
		attr_accessor :name, :longname, :synonyms
		def keywords
			Keywords.new "#{name} #{longname} #{synonyms}"
		end
		def longname
			@longname.to_s != '' ? @longname : name
		end
		def longname=(value)
			@longname = value
		end
		def description
			@description.to_s != '' ? @description : "Nothing special."
		end
		def description=(value)
			@description = value
		end
	end

end
