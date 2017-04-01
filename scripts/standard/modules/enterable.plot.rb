module Enterable
  attr_writer :enterable, :leave_verb, :enter_verb, :inside_verb
  def enterable?
    @enterable ||= false
  end
  def inside_verb
    @inside_verb ||= "be in"
  end
  def enter_verb
    @enter_verb ||= "enter"
  end
  def leave_verb
    @leave_verb ||= "leave"
  end
end
