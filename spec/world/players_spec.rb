describe Gamefic::World::Players do
  let(:object) {
    Object.new.extend Gamefic::World::Players
  }

  it 'uses Gamefic::Actor for the default class' do
    expect(object.player_class).to be(Gamefic::Actor)
  end

  it 'accepts a new player class' do
    klass = Class.new(Gamefic::Entity)
    klass.include(Gamefic::Active)
    object.set_player_class klass
    expect(object.player_class).to be(klass)
  end

  it 'raises an error for invalid player classes' do
    klass = Class.new(Gamefic::Entity)
    expect {
      object.set_player_class klass
    }.to raise_error(ArgumentError)
  end

  it 'creates a player character' do
    player = object.make_player_character
    expect(player).to be_a(object.player_class)
  end
end
