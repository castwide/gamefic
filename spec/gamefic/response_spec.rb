# frozen_string_literal: true

RSpec.describe Gamefic::Response do
  describe '#meta?' do
    it 'is false by default' do
      response = Gamefic::Response.new(:verb) {}
      expect(response.meta?).to be(false)
    end

    it 'is true when set' do
      response = Gamefic::Response.new(:verb, meta: true) {}
      expect(response.meta?).to be(true)
    end
  end

  describe '#accept?' do
    it 'accepts commands with valid arguments' do
      player = Gamefic::Actor.new
      entity = Gamefic::Entity.new(parent: player)
      response = Gamefic::Response.new(:verb, entity)
      command = Gamefic::Command.new(:verb, [entity])
      expect(response.accept?(player, command)).to be(true)
    end

    it 'rejects commands with different verbs' do
      player = Gamefic::Actor.new
      entity = Gamefic::Entity.new(parent: player)
      response = Gamefic::Response.new(:verb, entity)
      command = Gamefic::Command.new(:other, [entity])
      expect(response.accept?(player, command)).to be(false)
    end

    it 'rejects commands with invalid arguments' do
      player = Gamefic::Actor.new
      entity = Gamefic::Entity.new(parent: player)
      other = Gamefic::Entity.new
      response = Gamefic::Response.new(:verb, entity)
      command = Gamefic::Command.new(:verb, [other])
      expect(response.accept?(player, command)).to be(false)
    end
  end

  describe '#execute' do
    it 'runs blocks with arguments' do
      player = Gamefic::Actor.new
      response = Gamefic::Response.new(:verb) { |actor| actor[:executed] = true }
      response.execute(player)
      expect(player[:executed]).to be(true)
    end
  end
end
