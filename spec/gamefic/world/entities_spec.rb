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

  it 'raises IndexError for nonexistent picks' do
    expect {
      object.pick 'nothing'
    }.to raise_error(IndexError)
  end

  it 'raises IndexError for ambiguous picks' do
    object.make Gamefic::Entity, name: 'red thing'
    object.make Gamefic::Entity, name: 'blue thing'
    expect {
      object.pick 'thing'
    }.to raise_error(IndexError)
  end

  it 'raises ArgumentError for invalid classes' do
    expect {
      object.make(String)
    }.to raise_error(ArgumentError)
  end
end
