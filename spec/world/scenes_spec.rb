describe Gamefic::World::Scenes do
  let(:object) {
    object = Object.new
    object.extend Gamefic::World::Scenes
    object
  }

  it 'sets a default conclusion' do
    expect(object.default_conclusion).to be(Gamefic::Scene::Conclusion)
  end

  it 'tracks created scenes' do
    ps = object.pause { puts 'test' }
    expect(object.scene_classes).to include(ps)
  end
end
