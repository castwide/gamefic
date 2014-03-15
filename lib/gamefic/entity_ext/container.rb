require "gamefic/entity_ext/itemized"

module Gamefic

	class Container < Entity
		include Itemized
    def closeable=(bool)
      @closeable = bool
    end
    def closeable?
      @closeable ||= false
      if (@closeable == true && @closed == nil)
        @closed = false
      end
      @closeable
    end
    def closed?
      (@closed == true)
    end
    def closed=(bool)
      if bool == true
        @closeable = true
      end
      @closed = bool
    end
	end

end
