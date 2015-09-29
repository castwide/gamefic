module Gamefic::Arrangement
  LOCATED = 0
  ATTACHED = 1
  attr_writer :arrangement
  def arrangement
    @arrangement ||= LOCATED
  end
  def attached?
    @arrangement == ATTACHED
  end
  def attached=(bool)
    @arrangement = (bool ? ATTACHED : (@arrangement != ATTACHED ? @arrangement : LOCATED))
  end
end
