script 'standard/entities/receptacle'

class Container < Receptacle
  include Enterable
  include Openable
  include Lockable
  include Transparent
  
  serialize :enterable?, :open?, :locked?, :lock_key, :transparent?
  
end
