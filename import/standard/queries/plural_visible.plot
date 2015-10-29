require 'standard/queries/ambiguous_visible'

class Gamefic::Query::PluralVisible < Gamefic::Query::AmbiguousVisible
  def execute(subject, description)
    if !description.end_with?("s") and !description.end_with?("i") and !description.end_with?("ae")
      return Gamefic::Query::Matches.new([], '', description)
    end
    super
  end
end

module Gamefic::Use
  def self.plural_visible *args
    Gamefic::Query::PluralVisible.new *args
  end
end
