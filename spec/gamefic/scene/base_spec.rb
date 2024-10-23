# frozen_string_literal: true

describe Gamefic::Scene::Base do
  let(:actor) { Gamefic::Actor.new }

  let(:base) { Gamefic::Scene::Base.new(actor) }

  it 'initializes Base props' do
    expect(base.props).to be_a(Gamefic::Props::Default)
  end

  describe '#finish' do
    it 'reads from the actor queue' do
      actor.queue.push 'command'
      base.play_and_finish
      expect(actor.queue).to be_empty
      expect(base.props.input).to eq('command')
    end
  end
end
