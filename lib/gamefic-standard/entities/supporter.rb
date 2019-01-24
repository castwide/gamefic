class Supporter < Thing
  include Enterable

  set_default enter_verb: 'get on'
  set_default leave_verb: 'get off'
  set_default inside_verb: 'be on'
end
