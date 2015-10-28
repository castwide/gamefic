require 'gamefic';module Gamefic;respond :read, Query::Visible.new do |actor, thing|
  actor.perform :look, thing
end
;end
