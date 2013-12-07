module Gamefic

  class Story < Plot
    def post_initialize
			Action.defaults.each {|a|
				add_action a
			}
			Syntax.defaults.each {|s|
				add_syntax s
			}
    end
  end

end
