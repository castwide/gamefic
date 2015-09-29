class Gamefic::Container < Gamefic::Entity
  include Enterable
  include Openable
  include Lockable
  include Transparent
  
  serialize :enterable?, :open?, :locked?, :lock_key, :transparent?
  
end
