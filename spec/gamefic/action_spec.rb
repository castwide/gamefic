# frozen_string_literal: true

describe Gamefic::Action do
  let(:actor) { Gamefic::Actor.new }

  describe '#valid?' do
    it 'returns true for valid argument lengths' do
      response = Gamefic::Response.new(:verb) {}
      request = Gamefic::Response::Request.new(response, [])
      action = Gamefic::Action.new(actor, request)
      expect(action).to be_valid
      expect(action).not_to be_invalid
    end

    it 'returns false for invalid argument lengths' do
      response = Gamefic::Response.new(:verb, 'text') {}
      request = Gamefic::Response::Request.new(response, [])
      action = Gamefic::Action.new(actor, request)
      expect(action).to be_invalid
      expect(action).not_to be_valid
    end

    it 'returns true for valid argument queries' do
      thing = Gamefic::Entity.new name: 'thing', parent: actor
      response = Gamefic::Response.new(:verb, thing) {}
      request = Gamefic::Response::Request.new(response, [Gamefic::Query::Result.new(thing, '')])
      action = Gamefic::Action.new(actor, request)
      expect(action).to be_valid
      expect(action).not_to be_invalid
    end
  end

  describe '#execute' do
    it 'runs a valid action' do
      thing = Gamefic::Entity.new parent: actor
      response = Gamefic::Response.new :verb, thing do |actor|
        actor[:executed] = true
      end
      request = Gamefic::Response::Request.new(response, [Gamefic::Query::Result.new(thing, '')])
      action = Gamefic::Action.new(actor, request)
      expect(action.execute).to be(action)
      expect(actor[:executed]).to be(true)
    end
  end
end
