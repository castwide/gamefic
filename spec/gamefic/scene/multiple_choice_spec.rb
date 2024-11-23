# frozen_string_literal: true

describe Gamefic::Scene::MultipleChoice do
  let(:actor) { Gamefic::Actor.new }

  let(:multiple_choice) do
    Class.new(Gamefic::Scene::MultipleChoice) do |scene|
      scene.on_finish { |_, props| raise 'should not happen' unless props.index }
    end.new(actor)
  end

  it 'initializes MultipleChoice props' do
    expect(multiple_choice.props).to be_a(Gamefic::Props::MultipleChoice)
  end

  it 'outputs options on start' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    multiple_choice.start
    expect(multiple_choice.props.output[:options]).to eq(['one', 'two', 'three'])
  end

  it 'sets props on valid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor.queue.push 'one'
    expect { multiple_choice.play_and_finish }.not_to raise_error
    expect(actor.queue).to be_empty
    expect(multiple_choice.props.input).to eq('one')
    expect(multiple_choice.props.selection).to eq('one')
    expect(multiple_choice.props.index).to eq(0)
    expect(multiple_choice.props.number).to eq(1)
  end

  it 'cancels on invalid input' do
    multiple_choice.props.options.concat ['one', 'two', 'three']
    actor.queue.push 'four'
    expect { multiple_choice.play_and_finish }.not_to raise_error
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
  end
end
