describe Gamefic::Scene::Type::MultipleChoice do
  it 'initializes MultipleChoice props' do
    type = Gamefic::Scene::Type::MultipleChoice.new
    expect(type.props).to be_a(Gamefic::Scene::Props::MultipleChoice)
  end

  it 'sets props on valid input' do
    type = Gamefic::Scene::Type::MultipleChoice.new
    type.props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'one'
    type.finish actor
    expect(actor.queue).to be_empty
    expect(type).not_to be_cancelled
    expect(type.props.input).to eq('one')
    expect(type.props.selection).to eq('one')
    expect(type.props.index).to eq(0)
    expect(type.props.number).to eq(1)
  end

  it 'cancels on invalid input' do
    type = Gamefic::Scene::Type::MultipleChoice.new
    type.props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'four'
    type.finish actor
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
    expect(type).to be_cancelled
  end
end
