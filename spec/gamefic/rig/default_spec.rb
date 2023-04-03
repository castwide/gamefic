describe Gamefic::Rig::Default do
  let(:base) { Gamefic::Rig::Default.new(nil) }

  it 'initializes Base props' do
    expect(base.props).to be_a(Gamefic::Props::Default)
  end

  it 'reads from the actor queue' do
    actor = Gamefic::Actor.new
    actor.queue.push 'command'
    base.finish(actor)
    expect(actor.queue).to be_empty
    expect(base.props.input).to eq('command')
  end
end
