# Frozen_string_literal: true

RSpec.describe Gamefic::Response do
  describe '#meta?' do
    it 'is false by default' do
      response = Gamefic::Response.new(:verb) { |actor| actor }
      expect(response).not_to be_meta
    end

    it 'is true when set' do
      response = Gamefic::Response.new(:verb, meta: true) { |actor| actor }
      expect(response).to be_meta
    end
  end

  describe '#attempt' do
    it 'returns actions for valid commands' do
      response = Gamefic::Response.new(:verb) { |actor| actor }
      actor = Gamefic::Actor.new
      command = Gamefic::Command.new(:verb, [])
      action = response.attempt(actor, command)
      expect(action).to be_a(Gamefic::Action)
    end

    it 'returns nil for invalid commands' do
      response = Gamefic::Response.new(:verb) { |actor| actor }
      actor = Gamefic::Actor.new
      command = Gamefic::Command.new(:invalid, [])
      action = response.attempt(actor, command)
      expect(action).to be_nil
    end
  end
end
