require 'json'
import 'snapshots'

meta :save do |actor|
  ss = Snapshots.history.last
  if ss.nil?
    actor.tell "Nothing to save."
  else
    json = JSON.generate(ss)
    puts json
    File.open('game.sav', 'w') do |f|
      f.write json
    end
    actor.tell "Game saved."
  end
end

meta :restore do |actor|
  if File.exists?('game.sav')
    json = File.read('game.sav')
    data = JSON.parse(json, :symbolize_names => true)
    Snapshots.restore(data, self)
    actor.tell "Game restored."
  else
    actor.tell "Nothing to restore."
  end
end
