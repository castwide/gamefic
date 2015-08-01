module Gamefic::Query
  class Subquery < Base
    def base_specificity
      40
    end
    def initialize *arguments
      if arguments[0].kind_of?(Query::Base)
        @parent = arguments.shift
      else
        @parent = Query.last_new
      end
      super
    end
    def context_from(subject)
      last = @parent.last_match_for(subject)
      return [] if last.nil? or last.objects.length != 1
      last.objects[0].children
    end
  end
  def self.subquery *args
    Subquery.new *args
  end
end
