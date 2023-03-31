describe Gamefic::Scene::Rig::Base do
  it 'initializes Base props' do
    type = Gamefic::Scene::Rig::Base.new
    expect(type.props).to be_a(Gamefic::Scene::Props::Base)
  end

  it 'reads from the actor queue' do
    type = Gamefic::Scene::Rig::Base.new
    actor = Gamefic::Actor.new
    actor.queue.push 'command'
    type.finish(actor)
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
  end
end