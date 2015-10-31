class Character
  def hints
    @hints ||= []
  end
  def hint message
    hints.push message
    if self.is? :strongly_guided
      self.stream "<p class=\"hint\">#{message}</p>"
    end
  end
end

options Character, :lightly_guided, :strongly_guided, :never_guided

finish_action :reset_hints do |actor|
  actor.hints.clear
end

meta :hint do |actor|
  if !actor.is? :never_guided
    if actor.hints.length > 0
      actor.hints.each { |hint|
        actor.tell hint
      }
    else
      actor.tell "There are no hints available right now."
    end
  else
    actor.tell "There are no hints available in this game."
  end
end
