describe Gamefic::Scene::Rig::Base do
  let(:base) { Gamefic::Scene::Rig::Base.new(nil) }

  it 'initializes Base props' do
    expect(base.props).to be_a(Gamefic::Scene::Props::Base)
  end

  it 'reads from the actor queue' do
    actor = Gamefic::Actor.new
    actor.queue.push 'command'
    base.finish(actor)
    expect(actor.queue).to be_empty
    expect(base.props.input).to eq('command')
  end
end
