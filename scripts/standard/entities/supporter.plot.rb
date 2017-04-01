class Supporter < Gamefic::Entity
  include Enterable
  serialize :enterable?
  def initialize(args = {})
    self.enter_verb = "get on"
    self.leave_verb = "get off"
    self.inside_verb = "be on"
    super
  end
end
