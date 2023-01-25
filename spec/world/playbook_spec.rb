describe Gamefic::World::Playbook do
  let(:playbook) { Gamefic::World::Playbook.new }

  let(:actor) do
    Gamefic::Actor.new do |actor|
      actor.playbooks.push playbook
    end
  end

  it "creates an action" do
    playbook.respond :command do; end
    expect(playbook.actions.length).to eq(1)
    expect(playbook.actions.first.verb).to eq(:command)
  end

  it "creates a meta action" do
    playbook.meta :command do; end
    expect(playbook.actions.length).to eq(1)
    expect(playbook.actions.first.verb).to eq(:command)
    expect(playbook.actions.first).to be_meta
  end

  it "tracks verbs" do
    playbook.respond :command do; end
    expect(playbook.verbs).to eq([:command])
  end

  it "dispatches commands" do
    action = playbook.respond(:command) do; end
    dispatcher = playbook.dispatch(actor, 'command')
    result = dispatcher.next
    expect(result).to be_a(action)
  end

  it "marks actions as meta" do
    action = playbook.meta :verb
    expect(action.meta?).to be true
  end

  it "returns an executable action" do
    num = 0
    action = playbook.respond :increment do
      num += 1
    end
    action.new(Gamefic::Actor.new, nil).execute
    expect(num).to eq 1
  end

  it "registers an action's verb'" do
    playbook.respond :verb do
    end
    expect(playbook.verbs.length).to eq 1
    expect(playbook.actions_for(:verb).length).to eq 1
  end

  it "freezes commands and syntaxes" do
    playbook.freeze
    expect {
      playbook.respond :verb do
      end
    }.to raise_error(RuntimeError)
  end

  it "requires a syntax's translation to exist'" do
    expect {
      playbook.interpret "foo :thing", "bar :thing"
    }.to raise_error(RuntimeError)
  end

  it "translates to existing verbs" do
    playbook.respond :bar do
    end
    playbook.interpret "foo :thing", "bar :thing"
    expect(playbook.syntaxes.length).to eq 2
  end

  it "generates default syntaxes" do
    playbook.respond :verb do
    end
    expect(playbook.syntaxes.length).to eq 1
    syntax = playbook.syntaxes.first
    expect(syntax.verb).to eq :verb
  end

  it 'runs before_action hooks' do
    playbook.before_action do |action|
      action.actor[:executed] = true
    end

    playbook.respond :command do |actor|
    end

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it 'cancels actions from before_action hooks' do
    actor[:executed] = false

    playbook.before_action do |action|
      action.cancel
    end

    playbook.respond :command do |actor|
      actor[:executed] = true
    end

    actor.perform 'command'
    expect(actor[:executed]).to be(false)
  end

  it 'runs after_action hooks' do
    playbook.after_action do |action|
      action.actor[:executed] = true
    end

    playbook.respond :command do |actor|
    end

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it "dispatches the most recently declared action first" do
    num = 0
    playbook.respond :command do
      num = 1
    end
    playbook.respond :command do
      num = 2
    end
    playbook.respond :dummy, Gamefic::Query::Base.new do
      # noop
    end
    playbook.respond :command do
      num = 3
    end
    actor.perform 'command'
    expect(num).to eq(3)
  end

  it "returns all actions independently of verbs" do
    playbook.respond :action1 do;end
    playbook.respond :action2 do;end
    expect(playbook.actions.length).to eq(2)
  end

  it 'skips duplicate syntaxes' do
    playbook.respond(:make, Gamefic::Query::Family.new, Gamefic::Query::Family.new) { |_, _, _| }
    # Making the action creates a default syntax `make :var1 :var2`
    expect(playbook.syntaxes.length).to eq(1)
    playbook.interpret 'make :a from :b', 'make :a :b'
    playbook.interpret 'make :x from :y', 'make :x :y'
    # The above syntaxes are equivalent, so the second is ignored
    expect(playbook.syntaxes.length).to eq(2)
  end
end
