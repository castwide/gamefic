describe Gamefic::World::Scenebook do
  it 'adds a scene' do
    scenebook = Gamefic::World::Scenebook.new
    scene = Gamefic::Scene.new(:scene)
    scenebook.add scene
    expect(scenebook[:scene]).to be_a(Gamefic::Scene)
  end

  it 'blocks a scene' do
    scenebook = Gamefic::World::Scenebook.new
    scenebook.block :scene
    expect(scenebook[:scene]).to be_a(Gamefic::Scene)
  end

  it 'raises NameError if scene name exists' do
    scenebook = Gamefic::World::Scenebook.new
    scenebook.block :scene
    expect { scenebook.block :scene }.to raise_error(NameError)
  end
end
