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

    it 'returns nil with an empty query match' do
      defn = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
      response = Gamefic::Response.new(:verb, defn) { |actor| actor }
      actor = Gamefic::Actor.new
      command = Gamefic::Command.new(:verb, ['arg'])
      action = response.attempt(actor, command)
      expect(action).to be_nil
    end

    it 'returns an action with a successful token match' do
      defn = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
      response = Gamefic::Response.new(:verb, defn) { |actor| actor }

      room = Gamefic::Entity.new
      actor = Gamefic::Actor.new(parent: room)
      thing = Gamefic::Entity.new(parent: room, name: 'thing')

      command = Gamefic::Command.new(:verb, ['thing'])
      action = response.attempt(actor, command)
      expect(action).to be_a(Gamefic::Action)
      expect(action.arguments.first).to be(thing)
    end

    it 'returns nil with a failed token match' do
      defn = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
      response = Gamefic::Response.new(:verb, defn) { |actor| actor }

      room = Gamefic::Entity.new
      actor = Gamefic::Actor.new(parent: room)
      _thing = Gamefic::Entity.new(parent: room, name: 'thing')

      command = Gamefic::Command.new(:verb, ['unmatched'])
      action = response.attempt(actor, command)
      expect(action).to be_nil
    end

    it 'returns nil with ambiguous results' do
      defn = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
      response = Gamefic::Response.new(:verb, defn) { |actor| actor }

      room = Gamefic::Entity.new
      actor = Gamefic::Actor.new(parent: room)
      Gamefic::Entity.new(parent: room, name: 'red thing')
      Gamefic::Entity.new(parent: room, name: 'blue thing')

      command = Gamefic::Command.new(:verb, ['thing'])
      action = response.attempt(actor, command)
      expect(action).to be_nil
    end

    it 'returns ambiguous results when defined' do
      defn = Gamefic::Query::Scoped.new(Gamefic::Scope::Family, ambiguous: true)
      response = Gamefic::Response.new(:verb, defn) { |actor| actor }

      room = Gamefic::Entity.new
      actor = Gamefic::Actor.new(parent: room)
      thing1 = Gamefic::Entity.new(parent: room, name: 'red thing')
      thing2 = Gamefic::Entity.new(parent: room, name: 'blue thing')

      command = Gamefic::Command.new(:verb, ['thing'])
      action = response.attempt(actor, command)
      expect(action).to be_a(Gamefic::Action)
      expect(action.arguments).to eq([[thing1, thing2]])
    end
  end
end
