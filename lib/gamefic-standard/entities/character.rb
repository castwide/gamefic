class Character < Thing
  include Gamefic::Active
end

Gamefic.script do
  player_class Character
end
