describe Gamefic::Scene::Base do
  it "tracks finished attribute" do
    actor = Gamefic::Actor.new
    base = Scene::Base.new(actor)
    expect(base.finished?).to be(false)
    base.finish
    expect(base.finished?).to be(true)
  end
end
