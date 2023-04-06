describe Gamefic::Scenebook do
  it 'adds a scene' do
    scenebook = Gamefic::Scenebook.new
    scene = Gamefic::Scene.new(:scene)
    scenebook.add scene
    expect(scenebook.scenes).to eq([scene])
  end
end
