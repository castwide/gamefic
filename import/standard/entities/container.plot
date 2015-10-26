require 'standard/entities/receptacle'

class Gamefic::Container < Gamefic::Receptacle
  include Enterable
  include Openable
  include Lockable
  include Transparent
  
  serialize :enterable?, :open?, :locked?, :lock_key, :transparent?
  
end
