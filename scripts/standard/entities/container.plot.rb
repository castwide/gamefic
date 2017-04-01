script 'standard/entities/receptacle'

class Container < Receptacle
  include Enterable
  include Openable
  include Lockable
  include Transparent
  
end
