# frozen_string_literal: true

RSpec.describe Gamefic::Order do
  describe '#to_actions' do
    it 'returns matching actions' do
      klass = Class.new(Gamefic::Plot) do
        respond(:verb1) {}
        respond(:verb2) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Order.new(player, :verb1, [])
      actions = request.to_actions
      expect(actions).to be_one
      expect(actions.first.verb).to be(:verb1)
    end

    it 'returns matching actions with arguments' do
      klass = Class.new(Gamefic::Plot) do
        respond(:verb, anywhere(Gamefic::Entity)) {}
      end
      plot = klass.new
      player = plot.introduce
      thing = plot.make(Gamefic::Entity, name: 'thing')
      request = Gamefic::Order.new(player, :verb, [thing])
      actions = request.to_actions
      expect(actions).to be_one
      expect(actions.first.verb).to be(:verb)
      expect(actions.first.arguments).to eq([thing])
    end

    it 'skips responses with unmatched arguments' do
      klass = Class.new(Gamefic::Plot) do
        construct :thing1, Gamefic::Entity, name: 'thing1'
        construct :thing2, Gamefic::Entity, name: 'thing2'
        respond(:verb, anywhere(thing1)) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Order.new(player, :verb, [plot.thing2])
      actions = request.to_actions
      expect(actions).to be_empty
    end

    it 'matches unicode characters' do
      klass = Class.new(Gamefic::Plot) do
        construct :thing, Gamefic::Entity, name: 'ꩺ'
        respond('ぇワ', anywhere) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Order.new(player, :'ぇワ', [plot.thing])
      actions = request.to_actions
      expect(actions).to be_one
      expect(actions.first.verb).to be('ぇワ'.to_sym)
    end
  end
end
