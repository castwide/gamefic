# frozen_string_literal: true

describe Gamefic::Scene::YesOrNo do
  let(:actor) { Gamefic::Actor.new }

  let(:yes_or_no) { Gamefic::Scene::YesOrNo.new(actor) }

  it 'initializes YesOrNo props' do
    expect(yes_or_no.props).to be_a(Gamefic::Props::YesOrNo)
  end

  it 'freezes options' do
    expect { yes_or_no.props.options.concat ['maybe'] }.to raise_error(FrozenError)
  end

  it 'flags yes?' do
    actor.queue.push 'yes'
    yes_or_no.play_and_finish
    expect(actor.queue).to be_empty
    expect(yes_or_no.props.input).to eq('yes')
    expect(yes_or_no.props.selection).to eq('Yes')
    expect(yes_or_no.props.index).to eq(0)
    expect(yes_or_no.props.number).to eq(1)
    expect(yes_or_no.props).to be_yes
  end

  it 'flags no?' do
    actor.queue.push 'no'
    yes_or_no.play_and_finish
    expect(actor.queue).to be_empty
    expect(yes_or_no.props.input).to eq('no')
    expect(yes_or_no.props.selection).to eq('No')
    expect(yes_or_no.props.index).to eq(1)
    expect(yes_or_no.props.number).to eq(2)
    expect(yes_or_no.props).to be_no
  end

  it 'cancels on invalid input' do
    actor.queue.push 'maybe'
    yes_or_no.play_and_finish
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('not a valid choice')
  end
end
