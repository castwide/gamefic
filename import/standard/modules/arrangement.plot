module Gamefic::Arrangement
  LOCATED = :located
  ATTACHED = :attached
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
