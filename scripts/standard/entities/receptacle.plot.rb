class Receptacle < Gamefic::Entity
  include Enterable
  serialize :enterable?, :enter_verb, :leave_verb, :inside_verb
end
