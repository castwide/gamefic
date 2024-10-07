# frozen_string_literal: true

describe Gamefic::Scene::MultipleChoice do
  let(:multiple_choice) do
    Gamefic::Scene::MultipleChoice.new(nil) do |scene|
      scene.on_finish { |_, props| raise unless props.index }
    end
  end

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
    expect {
      multiple_choice.run_finish_blocks(actor, props)
    }.not_to raise_error
  end

  it 'cancels on invalid input' do
    props = multiple_choice.new_props
    props.options.concat ['one', 'two', 'three']
    actor = Gamefic::Actor.new
    actor.queue.push 'four'
    multiple_choice.finish actor, props
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('"four" is not a valid choice.')
    expect {
      multiple_choice.run_finish_blocks(actor, props)
    }.not_to raise_error
  end
end
