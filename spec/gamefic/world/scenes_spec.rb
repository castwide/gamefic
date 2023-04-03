describe Gamefic::World::Scenes do
  let(:object) { Object.new.tap { |obj| obj.extend Gamefic::World::Scenes } }

  it 'has a scenebook' do
    expect(object.scenebook).to be_a(Gamefic::Scenebook)
  end

  it 'blocks a scene' do
    object.block(:scene)
    expect(object.scenebook[:scene]).to be_a(Gamefic::Scene)
  end

  it 'has a default scene' do
    expect(object.default_scene).to be_a(Gamefic::Scene)
    expect(object.default_scene.rig).to be(Gamefic::Scene::Rig::Activity)
  end

  it 'has a default conclusion' do
    expect(object.default_conclusion).to be_a(Gamefic::Scene)
    expect(object.default_conclusion.rig).to be(Gamefic::Scene::Rig::Conclusion)
  end

  it 'sets a default scene' do
    scene = object.block(:default_scene, rig: Gamefic::Scene::Rig::MultipleChoice)
    expect(object.default_scene).to be(scene)
  end

  it 'sets a default conclusion' do
    scene = object.block(:default_conclusion, rig: Gamefic::Scene::Rig::MultipleChoice)
    expect(object.default_conclusion).to be(scene)
  end

  it 'sets an introduction' do
    scene = object.introduction do |actor|
      actor.tell 'Hello, world!'
    end
    expect(object.scenebook[:introduction]).to be(scene)
  end

  it 'introduces a player' do
    object.introduction do |actor|
      actor.tell 'Hello, world!'
    end
    actor = Gamefic::Actor.new
    object.introduce actor
    expect(actor.playbooks).to include(object.playbook)
    expect(actor.scenebooks).to include(object.scenebook)
    take = actor.start_cue nil
    expect(take.scene.name).to be(:introduction)
  end

  it 'creates a MultipleChoice scene' do
    scene = object.multiple_choice :multi, ['Choice 1', 'Choice 2'] do |scene|
      scene.on_finish do |actor, props|
        actor.tell "You chose #{props.selection}"
      end
    end
    expect(scene.rig).to be(Gamefic::Scene::Rig::MultipleChoice)
    expect(object.scenebook[:multi]).to be(scene)
  end

  it 'creates a YesOrNo scene' do
    scene = object.yes_or_no :question do |scene|
      scene.on_finish do |actor, props|
        actor.tell "You chose #{props.selection}"
      end
    end
    expect(scene.rig).to be(Gamefic::Scene::Rig::YesOrNo)
    expect(object.scenebook[:question]).to be(scene)
  end

  it 'creates a Pause scene' do
    scene = object.pause :denouement, next_cue: :default_conclusion do |scene|
      scene.on_start do |actor|
        actor.tell "You're in the denouement."
      end
    end
    expect(scene.rig).to be(Gamefic::Scene::Rig::Pause)
    expect(object.scenebook[:denouement]).to be(scene)
  end

  it 'creates a Conclusion scene' do
    scene = object.conclusion :ending do |scene|
      scene.on_start do |actor|
        actor.tell "GAME OVER"
      end
    end
    expect(scene.rig).to be(Gamefic::Scene::Rig::Conclusion)
    expect(object.scenebook[:ending]).to be(scene)
  end

  it 'renders messages in output' do
    object.pause :pause do |actor|
      actor.tell 'Pause scene'
    end
    actor = Gamefic::Actor.new
    object.introduce actor
    actor.cue :pause
    object.ready
    expect(actor.output[:messages]).to include('Pause scene')
  end

  it 'renders player output from callbacks' do
    object.on_player_output do |_actor, output|
      output[:extra] = 'data from callback'
    end
    actor = Gamefic::Actor.new
    object.introduce actor
    object.ready
    expect(actor.output[:extra]).to eq('data from callback')
  end
end
