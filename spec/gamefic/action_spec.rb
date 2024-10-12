# frozen_string_literal: true

describe Gamefic::Action do
  let(:actor) { Gamefic::Actor.new }

  describe '#valid?' do
    it 'returns true for valid argument lengths' do
      command = Gamefic::Command.new(:verb, [])
      response = Gamefic::Response.new(:verb) {}
      action = Gamefic::Action.new(actor, command, response)
      expect(action).to be_valid
      expect(action).not_to be_invalid
    end

    it 'returns false for invalid argument lengths' do
      command = Gamefic::Command.new(:verb, [])
      response = Gamefic::Response.new(:verb, 'text') {}
      action = Gamefic::Action.new(actor, command, response)
      expect(action).to be_invalid
      expect(action).not_to be_valid
    end

    it 'returns true for valid argument queries' do
      thing = Gamefic::Entity.new name: 'thing', parent: actor
      command = Gamefic::Command.new(:verb, [thing])
      response = Gamefic::Response.new(:verb, thing) {}
      action = Gamefic::Action.new(actor, command, response)
      expect(action).to be_valid
      expect(action).not_to be_invalid
    end
  end

  describe '#execute' do
    it 'runs a valid action' do
      thing = Gamefic::Entity.new parent: actor
      command = Gamefic::Command.new(:verb, [thing])
      response = Gamefic::Response.new :verb, thing do |actor|
        actor[:executed] = true
      end
      action = Gamefic::Action.new(actor, command, response)
      expect(action.execute).to be(action)
      expect(actor[:executed]).to be(true)
    end
  end
end
