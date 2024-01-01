# frozen_string_literal: true

describe Gamefic::Delegatable::Events do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) do
    klass = Class.new do
      include Gamefic::Delegatable::Events

      attr_accessor :rulebook
    end

    klass.new.tap do |obj|
      obj.rulebook = Gamefic::Rulebook.new(stage_func)
    end
  end

  describe '#on_conclude' do
    it 'adds an on_conclude block' do
      object.on_conclude { nil }
      expect(object.rulebook.events.conclude_blocks).to be_one
    end
  end

  describe '#on_player_output' do
    it 'adds an on_player_output block' do
      object.on_player_output { |_player, _output| nil }
      expect(object.rulebook.events.player_output_blocks).to be_one
    end
  end
end
