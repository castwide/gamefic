module Gamefic
  module Plot::ArticleMount
    def a(entity)
      entity.indefinitely
    end
    def an(entity)
      entity.indefinitely
    end
    def the(entity)
      entity.definitely
    end
    def A(entity)
      entity.indefinitely.cap_first
    end
    def An(entity)
      entity.indefinitely.cap_first
    end
    def The(entity)
      entity.definitely.cap_first
    end
  end
end
