class Character < Thing
  #include ParentRoom
  #include Attachable
  #include Itemizable
  #include AutoTakes
  #include LocaleDescription
  include Gamefic::Active
end

player_class Character
