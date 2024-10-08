# frozen_string_literal: true

describe Gamefic::Scene::Default do
  let(:base) { Gamefic::Scene::Default.new }

  it 'initializes Base props' do
    expect(base.new_props).to be_a(Gamefic::Props::Default)
  end

  describe '#start' do
    it 'sets base output' do
      actor = Gamefic::Actor.new
      actor.queue.push 'command'
      props = base.new_props
      base.start(actor, props)
      expect(props.output[:scene]).to eq(base.to_hash)
      expect(props.output[:prompt]).to eq(props.prompt)
    end
  end

  describe '#finish' do
    it 'reads from the actor queue' do
      actor = Gamefic::Actor.new
      actor.queue.push 'command'
      props = base.new_props
      base.finish(actor, props)
      expect(actor.queue).to be_empty
      expect(props.input).to eq('command')
    end
  end
end
