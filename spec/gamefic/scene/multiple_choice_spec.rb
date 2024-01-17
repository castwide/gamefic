describe Gamefic::Scene::MultipleChoice do
  let(:multiple_choice) { Gamefic::Scene::MultipleChoice.new(nil, nil) }

  it 'initializes MultipleChoice props' do
    expect(multiple_choice.new_props).to be_a(Gamefic::Props::MultipleChoice)
  end

  it 'sets props on valid input' do
    props = multiple_choice.new_props
    props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'one'
    multiple_choice.finish actor, props
    expect(actor.queue).to be_empty
    expect(props.input).to eq('one')
    expect(props.selection).to eq('one')
    expect(props.index).to eq(0)
    expect(props.number).to eq(1)
  end

  it 'cancels on invalid input' do
    props = multiple_choice.new_props
    props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'four'
    multiple_choice.finish actor, props
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
  end
end
