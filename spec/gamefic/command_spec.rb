# frozen_string_literal: true

describe Gamefic::Command do
  it 'prefers stricter matches' do
    subclass = Class.new(Gamefic::Entity)

    klass = Class.new(Gamefic::Plot) do
      make_seed Gamefic::Entity, name: 'room'
      make_seed Gamefic::Entity, name: 'bag', parent: lazy_pick('room')
      make_seed subclass, name: 'bagel', parent: lazy_pick('room')

      introduction do |actor|
        actor.parent = pick!('room')
      end

      respond :look, Gamefic::Entity do |actor, thing|
        actor.stream thing.name
      end

      respond :look, subclass do |actor, thing|
        actor.stream thing.name
      end
    end

    plot = klass.new
    player = plot.introduce
    command = Gamefic::Command.compose(player, 'look bag')
    expect(command.arguments.first).to be(plot.pick!('bag'))
  end
end
