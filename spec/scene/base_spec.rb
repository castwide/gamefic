describe Gamefic::Scene::Base do
  it "tracks finished attribute" do
    actor = Gamefic::Actor.new
    base = Gamefic::Scene::Base.new(actor)
    expect(base.finished?).to be(false)
    base.finish
    expect(base.finished?).to be(true)
  end

  it "tracks entries" do
    klass = Gamefic::Scene::Base.subclass
    klass.tracked = true
    actor = Gamefic::Actor.new
    expect(actor.entered?(klass)).to be(false)
    scene = klass.new(actor)
    scene.start
    expect(actor.entered?(klass)).to be(true)
    expect(actor.entered?(scene)).to be(true)
  end

  it 'populates the data hash' do
    scene = Gamefic::Scene::Base.new(nil, foo: 'bar')
    expect(scene[:foo]).to eq('bar')
  end
end
