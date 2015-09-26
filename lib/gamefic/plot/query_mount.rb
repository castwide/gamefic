module Gamefic
  module Plot::QueryMount
  end
  module Query
    def self.siblings *arguments
      Siblings.new *arguments
    end
  end
end
