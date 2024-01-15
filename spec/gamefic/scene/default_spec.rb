describe Gamefic::Scene::Default do
  let(:base) { Gamefic::Scene::Default.new(nil, nil) }

  it 'initializes Base props' do
    expect(base.new_props).to be_a(Gamefic::Props::Default)
  end

  it 'reads from the actor queue' do
    actor = Gamefic::Actor.new
    actor.queue.push 'command'
    props = base.new_props
    base.finish?(actor, props)
    expect(actor.queue).to be_empty
    expect(props.input).to eq('command')
  end
end
