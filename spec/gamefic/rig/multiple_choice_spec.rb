describe Gamefic::Rig::MultipleChoice do
  let(:multiple_choice) { Gamefic::Rig::MultipleChoice.new(nil) }

  it 'initializes MultipleChoice props' do
    expect(multiple_choice.props).to be_a(Gamefic::Props::MultipleChoice)
  end

  it 'sets props on valid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'one'
    multiple_choice.finish actor
    expect(actor.queue).to be_empty
    expect(multiple_choice).not_to be_cancelled
    expect(multiple_choice.props.input).to eq('one')
    expect(multiple_choice.props.selection).to eq('one')
    expect(multiple_choice.props.index).to eq(0)
    expect(multiple_choice.props.number).to eq(1)
  end

  it 'cancels on invalid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'four'
    multiple_choice.finish actor
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
    expect(multiple_choice).to be_cancelled
  end
end
