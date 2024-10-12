# frozen_string_literal: true

describe Gamefic::Scriptable::Events do
  let(:object) do
    klass = Class.new do
      extend Gamefic::Scriptable
    end
  end

  describe '#on_conclude' do
    it 'adds an on_conclude block' do
      object.on_conclude { nil }
      expect(object.conclude_blocks).to be_one
    end
  end

  describe '#on_player_output' do
    it 'adds an on_player_output block' do
      object.on_player_output { |_player, _output| nil }
      expect(object.player_output_blocks).to be_one
    end
  end
end
