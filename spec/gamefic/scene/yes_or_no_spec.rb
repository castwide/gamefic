describe Gamefic::Scene::YesOrNo do
  let(:yes_or_no) { Gamefic::Scene::YesOrNo.new(nil, nil) }

  it 'initializes YesOrNo props' do
    expect(yes_or_no.new_props).to be_a(Gamefic::Props::YesOrNo)
  end

  it 'freezes options' do
    expect { yes_or_no.new_props.options.concat ['maybe'] }.to raise_error(FrozenError)
  end

  it 'flags yes?' do
    actor = Gamefic::Actor.new
    actor.queue.push 'yes'
    props = yes_or_no.new_props
    response = yes_or_no.finish?(actor, props)
    expect(response).to be(true)
    expect(actor.queue).to be_empty
    expect(props.input).to eq('yes')
    expect(props.selection).to eq('Yes')
    expect(props.index).to eq(0)
    expect(props.number).to eq(1)
    expect(props).to be_yes
  end

  it 'flags no?' do
    actor = Gamefic::Actor.new
    actor.queue.push 'no'
    props = yes_or_no.new_props
    response = yes_or_no.finish?(actor, props)
    expect(response).to be(true)
    expect(actor.queue).to be_empty
    expect(props.input).to eq('no')
    expect(props.selection).to eq('No')
    expect(props.index).to eq(1)
    expect(props.number).to eq(2)
    expect(props).to be_no
  end

  it 'cancels on invalid input' do
    actor = Gamefic::Actor.new
    actor.queue.push 'maybe'
    props = yes_or_no.new_props
    response = yes_or_no.finish?(actor, props)
    expect(response).to be(false)
    expect(actor.queue).to be_empty
  end
end
