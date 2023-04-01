describe Gamefic::Scene::Rig::YesOrNo do
  let(:yes_or_no) { Gamefic::Scene::Rig::YesOrNo.new(nil) }

  it 'initializes YesOrNo props' do
    expect(yes_or_no.props).to be_a(Gamefic::Scene::Props::YesOrNo)
  end

  it 'freezes options' do
    expect { yes_or_no.props.options.concat ['maybe'] }.to raise_error(FrozenError)
  end

  it 'flags yes?' do
    actor = Gamefic::Actor.new
    actor.queue.push 'yes'
    yes_or_no.finish actor
    expect(actor.queue).to be_empty
    expect(yes_or_no).not_to be_cancelled
    expect(yes_or_no.props.input).to eq('yes')
    expect(yes_or_no.props.selection).to eq('Yes')
    expect(yes_or_no.props.index).to eq(0)
    expect(yes_or_no.props.number).to eq(1)
    expect(yes_or_no.props).to be_yes
  end

  it 'flags no?' do
    actor = Gamefic::Actor.new
    actor.queue.push 'no'
    yes_or_no.finish actor
    expect(actor.queue).to be_empty
    expect(yes_or_no).not_to be_cancelled
    expect(yes_or_no.props.input).to eq('no')
    expect(yes_or_no.props.selection).to eq('No')
    expect(yes_or_no.props.index).to eq(1)
    expect(yes_or_no.props.number).to eq(2)
    expect(yes_or_no.props).to be_no
  end

  it 'cancels on invalid input' do
    actor = Gamefic::Actor.new
    actor.queue.push 'maybe'
    yes_or_no.finish actor
    expect(actor.queue).to be_empty
    expect(yes_or_no).to be_cancelled
  end
end
