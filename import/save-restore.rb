require 'json'
import 'snapshots'

meta :save do |actor|
  actor.user.save "game.sav"
end

meta :save, Query::Text.new() do |actor, filename|
  actor.user.save filename
end

meta :restore do |actor|
  actor.user.restore "game.sav"
end

meta :restore, Query::Text.new() do |actor, filename|
  actor.user.restore filename
end
