# frozen_string_literal: true

RSpec.describe Gamefic::Request do
  describe '#to_actions' do
    it 'returns matching actions' do
      klass = Class.new(Gamefic::Plot) do
        respond(:verb1) {}
        respond(:verb2) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Request.new(player, 'verb1')
      actions = request.to_actions
      expect(actions).to be_one
      expect(actions.first.verb).to be(:verb1)
    end

    it 'matches unicode characters' do
      klass = Class.new(Gamefic::Plot) do
        construct :thing, Gamefic::Entity, name: 'ꩺ'
        respond('ぇワ', anywhere) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Request.new(player, 'ぇワ ꩺ')
      actions = request.to_actions
      expect(actions).to be_one
      expect(actions.first.verb).to be('ぇワ'.to_sym)
    end
  end

  describe '#to_command' do
    it 'returns a matching command' do
      klass = Class.new(Gamefic::Plot) do
        respond(:verb1) {}
        respond(:verb2) {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Request.new(player, 'verb1')
      command = request.to_command
      expect(command.verb).to be(:verb1)
    end

    it 'matches unicode characters' do
      klass = Class.new(Gamefic::Plot) do
        respond('ぇワ') {}
      end
      plot = klass.new
      player = plot.introduce
      request = Gamefic::Request.new(player, 'ぇワ')
      command = request.to_command
      expect(command.verb).to be('ぇワ'.to_sym)
    end
  end
end
