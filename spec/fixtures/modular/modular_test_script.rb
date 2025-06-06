# frozen_string_literal: true

module ModularTestScript
  extend Gamefic::Scriptable

  construct :place, Gamefic::Entity, name: 'place'

  construct :thing, Gamefic::Entity, name: 'thing', parent: place

  construct :unreferenced, Gamefic::Entity, name: 'unreferenced', parent: place

  respond :use, thing do |actor|
    actor[:used] = thing
  end
end
