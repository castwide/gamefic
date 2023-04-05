describe Gamefic::Scenebook do
  it 'adds a scene' do
    scenebook = Gamefic::Scenebook.new
    scene = Gamefic::Scene.new(:scene)
    scenebook.add scene
    expect(scenebook[:scene]).to be_a(Gamefic::Scene)
  end

  it 'raises NameError if scene name exists' do
    scenebook = Gamefic::Scenebook.new
    scene = Gamefic::Scene.new(:scene)
    scenebook.add scene
    expect { scenebook.add scene }.to raise_error(NameError)
  end
end
