describe Gamefic::Scene::Type::YesOrNo do
  it 'initializes YesOrNo props' do
    type = Gamefic::Scene::Type::YesOrNo.new
    expect(type.props).to be_a(Gamefic::Scene::Props::YesOrNo)
  end

  it 'freezes options' do
    type = Gamefic::Scene::Type::YesOrNo.new
    expect { type.props.options.concat ['maybe'] }.to raise_error(FrozenError)
  end

  it 'flags yes?' do
    type = Gamefic::Scene::Type::YesOrNo.new
    actor = Gamefic::Actor.new
    actor.queue.push 'yes'
    type.finish actor
    expect(actor.queue).to be_empty
    expect(type).not_to be_cancelled
    expect(type.props.input).to eq('yes')
    expect(type.props.selection).to eq('Yes')
    expect(type.props.index).to eq(0)
    expect(type.props.number).to eq(1)
    expect(type.props).to be_yes
  end

  it 'flags no?' do
    type = Gamefic::Scene::Type::YesOrNo.new
    actor = Gamefic::Actor.new
    actor.queue.push 'no'
    type.finish actor
    expect(actor.queue).to be_empty
    expect(type).not_to be_cancelled
    expect(type.props.input).to eq('no')
    expect(type.props.selection).to eq('No')
    expect(type.props.index).to eq(1)
    expect(type.props.number).to eq(2)
    expect(type.props).to be_no
  end

  it 'cancels on invalid input' do
    type = Gamefic::Scene::Type::YesOrNo.new
    actor = Gamefic::Actor.new
    actor.queue.push 'maybe'
    type.finish actor
    expect(actor.queue).to be_empty
    expect(type).to be_cancelled
  end
end
