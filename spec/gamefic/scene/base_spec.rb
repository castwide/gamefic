# frozen_string_literal: true

describe Gamefic::Scene::Base do
  let(:actor) { Gamefic::Actor.new }

  let(:base) { Gamefic::Scene::Base.new(actor) }

  it 'initializes Base props' do
    expect(base.props).to be_a(Gamefic::Props::Default)
  end

  describe '#start' do
    it 'sets base output' do
      actor.queue.push 'command'
      base.start
      expect(base.props.output[:scene]).to eq(base.to_hash)
      expect(base.props.output[:prompt]).to eq(base.props.prompt)
    end
  end

  describe '#finish' do
    it 'reads from the actor queue' do
      actor.queue.push 'command'
      base.finish
      expect(actor.queue).to be_empty
      expect(base.props.input).to eq('command')
    end
  end
end
