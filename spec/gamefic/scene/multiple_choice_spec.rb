# frozen_string_literal: true

describe Gamefic::Scene::MultipleChoice do
  let(:actor) { Gamefic::Actor.new }

  let(:multiple_choice) do
    Class.new(Gamefic::Scene::MultipleChoice) do |scene|
      scene.on_finish { |_, props| raise unless props.index }
    end.new(actor)
  end

  it 'initializes MultipleChoice props' do
    expect(multiple_choice.props).to be_a(Gamefic::Props::MultipleChoice)
  end

  it 'sets props on valid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor.queue.push 'one'
    multiple_choice.finish
    expect(actor.queue).to be_empty
    expect(multiple_choice.props.input).to eq('one')
    expect(multiple_choice.props.selection).to eq('one')
    expect(multiple_choice.props.index).to eq(0)
    expect(multiple_choice.props.number).to eq(1)
    expect {
      multiple_choice.run_finish_blocks
    }.not_to raise_error
  end

  it 'cancels on invalid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor.queue.push 'four'
    multiple_choice.finish
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
    expect { multiple_choice.run_finish_blocks }.not_to raise_error
  end
end
