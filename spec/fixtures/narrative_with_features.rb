# frozen_string_literal: true

class NarrativeWithFeatures < Gamefic::Narrative
  construct :thing, Gamefic::Entity, name: 'thing'
  respond(:command, thing) { nil }
end
