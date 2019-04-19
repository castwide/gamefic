describe Gamefic::World::Playbook do
  it "creates an action" do
    playbook = Gamefic::World::Playbook.new
    playbook.respond :command do; end
    expect(playbook.actions.length).to eq(1)
    expect(playbook.actions.first.verb).to eq(:command)
  end

  it "creates a meta action" do
    playbook = Gamefic::World::Playbook.new
    playbook.meta :command do; end
    expect(playbook.actions.length).to eq(1)
    expect(playbook.actions.first.verb).to eq(:command)
    expect(playbook.actions.first).to be_meta
  end

  it "tracks verbs" do
    playbook = Gamefic::World::Playbook.new
    playbook.respond :command do; end
    expect(playbook.verbs).to eq([:command])
  end

  it "creates validators" do
    playbook = Gamefic::World::Playbook.new
    playbook.validate do |actor, verb|
      true
    end
    expect(playbook.validators.length).to eq(1)
  end

  it "has a disambiguator" do
    playbook = Gamefic::World::Playbook.new
    actor = Gamefic::Actor.new
    one = Gamefic::Entity.new(name: 'one')
    two = Gamefic::Entity.new(name: 'two')
    playbook.disambiguator.new(actor, [[one, two]]).execute
    expect(actor.messages).to include('the one or the two')
  end

  it "sets a disambiguator" do
    playbook = Gamefic::World::Playbook.new
    playbook.disambiguate do |actor, entities|
      actor.tell entities.map(&:name).join(',')
    end
    actor = Gamefic::Actor.new
    one = Gamefic::Entity.new(name: 'one')
    two = Gamefic::Entity.new(name: 'two')
    playbook.disambiguator.new(actor, [[one, two]]).execute
    expect(actor.messages).to include('one,two')
  end

  it "dispatches commands" do
    playbook = Gamefic::World::Playbook.new
    playbook.respond :command do; end
    actor = Gamefic::Actor.new
    actor.playbooks.push playbook
    commands = playbook.dispatch(actor, 'command')
    expect(commands.length).to eq(1)
  end
end
