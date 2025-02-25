# frozen_string_literal: true

describe Gamefic::Scene::YesOrNo do
  let(:actor) { Gamefic::Actor.new }

  let(:yes_or_no) { Gamefic::Scene::YesOrNo.new(actor) }

  it 'initializes YesOrNo props' do
    expect(yes_or_no.props).to be_a(Gamefic::Props::YesOrNo)
  end

  it 'flags yes?' do
    yes_or_no.props.enter 'yes'
    yes_or_no.finish
    expect(actor.queue).to be_empty
    expect(yes_or_no.props.input).to eq('yes')
    expect(yes_or_no.props.selection).to eq('Yes')
    expect(yes_or_no.props.index).to eq(0)
    expect(yes_or_no.props.number).to eq(1)
    expect(yes_or_no.props).to be_yes
  end

  it 'flags no?' do
    yes_or_no.props.enter 'no'
    yes_or_no.finish
    expect(actor.queue).to be_empty
    expect(yes_or_no.props.input).to eq('no')
    expect(yes_or_no.props.selection).to eq('No')
    expect(yes_or_no.props.index).to eq(1)
    expect(yes_or_no.props.number).to eq(2)
    expect(yes_or_no.props).to be_no
  end

  it 'cancels on invalid input' do
    yes_or_no.props.enter 'maybe'
    yes_or_no.finish
    expect(actor.queue).to be_empty
    expect(actor.messages).to include('not a valid choice')
  end
end
