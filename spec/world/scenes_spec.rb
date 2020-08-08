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

  it 'creates a conclusion' do
    actor = Gamefic::Actor.new
    conclusion = object.conclusion do |actor|
      actor.tell "Concluded"
    end
    scene = conclusion.new(actor)
    expect(scene).to be_a(Gamefic::Scene::Conclusion)
    run scene
    expect(actor.messages).to include("Concluded")
  end

  it 'creates a question' do
    actor = Gamefic::Actor.new
    question = object.question do |actor, data|
      actor.tell data.input
    end
    scene = question.new(actor)
    expect(scene).to be_a(Gamefic::Scene::Custom)
    actor.queue.push "the answer"
    run scene
    expect(actor.messages).to include("the answer")
  end

  it 'creates a custom scene' do
    actor = Gamefic::Actor.new
    custom = object.custom do |actor|
      actor.tell "Custom"
    end
    scene = custom.new(actor)
    expect(scene).to be_a(Gamefic::Scene::Custom)
    run scene
    expect(actor.messages).to include("Custom")
  end

  def run scene
    scene.start
    scene.update
    scene.finish
  end
end
