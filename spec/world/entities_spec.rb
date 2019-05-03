describe Gamefic::World::Entities do
  let (:object) {
    object = Object.new
    object.extend Gamefic::World::Entities
  }

  it 'picks unique entities by description' do
    entity = object.make Gamefic::Entity, name: 'a bright red thing'
    result = object.pick 'bright red'
    expect(result).to be(entity)
  end
end
