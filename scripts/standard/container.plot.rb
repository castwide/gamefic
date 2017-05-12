script 'standard/openable'
script 'standard/lockable'
#script 'standard/container/entities'
#script 'standard/container/actions'

class Container < Receptacle
  include Openable
  include Lockable
  #include Transparent
end
