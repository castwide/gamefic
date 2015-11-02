module Suggestible
  def suggestions
    @suggestions ||= []
  end
  def suggest command
    suggestions.push command
  end
end
