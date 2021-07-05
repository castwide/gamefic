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

  it "dispatches commands" do
    playbook = Gamefic::World::Playbook.new
    action = playbook.respond(:command) do; end
    actor = Gamefic::Actor.new
    actor.playbooks.push playbook
    dispatcher = playbook.dispatch(actor, 'command')
    result = dispatcher.next
    expect(result).to be_a(action)
  end
end
