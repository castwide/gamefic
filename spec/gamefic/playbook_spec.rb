describe Gamefic::Playbook do
  let(:playbook) { Gamefic::Playbook.new }

  let(:actor) do
    Gamefic::Actor.new do |actor|
      actor.playbooks.add playbook
    end
  end

  it "creates an action" do
    playbook.respond_with Gamefic::Response.new(:command) {}
    expect(playbook.responses.length).to eq(1)
    expect(playbook.responses.first.verb).to eq(:command)
  end

  it "tracks verbs" do
    playbook.respond_with Gamefic::Response.new(:command) {}
    expect(playbook.verbs).to eq([:command])
  end

  it "freezes responses" do
    playbook.freeze
    expect {
      playbook.respond_with Gamefic::Response.new(:command) {}
    }.to raise_error(FrozenError)
  end

  it "freezes syntaxes" do
    playbook.respond_with Gamefic::Response.new(:look) { |_| nil }
    playbook.freeze
    expect {
      playbook.interpret_with Gamefic::Syntax.new('examine', 'look')
    }.to raise_error(FrozenError)
  end

  it 'freezes existing {verb: response} maps' do
    playbook.respond_with Gamefic::Response.new(:look) { |_| 0 }
    playbook.freeze
    expect { playbook.respond_with Gamefic::Response.new(:look) {} }.to raise_error(FrozenError)
  end

  it 'freezes existing {synonym: syntax} maps' do
    playbook.respond_with Gamefic::Response.new(:verb1) { |_| 0 }
    playbook.respond_with Gamefic::Response.new(:verb2) { |_| 0 }
    playbook.interpret_with Gamefic::Syntax.new('synonym', 'verb1')
    playbook.freeze
    expect { playbook.interpret_with Gamefic::Syntax.new('synonym', 'verb2') }.to raise_error(FrozenError)
  end

  it 'freezes before actions' do
    playbook.freeze
    expect {
      playbook.before_action { |_| nil }
    }.to raise_error(FrozenError)
  end

  it 'freezes after actions' do
    playbook.freeze
    expect {
      playbook.after_action { |_| nil }
    }.to raise_error(FrozenError)
  end

  it "requires a syntax's translation to exist'" do
    expect {
      playbook.interpret_with Gamefic::Syntax.new('foo :thing', 'bar :thing')
    }.to raise_error(RuntimeError)
  end

  it "translates to existing verbs" do
    playbook.respond_with Gamefic::Response.new(:bar) {}
    playbook.interpret_with Gamefic::Syntax.new("foo :thing", "bar :thing")
    expect(playbook.syntaxes.length).to eq 2
  end

  it "generates default syntaxes" do
    playbook.respond_with Gamefic::Response.new(:verb) {}
    expect(playbook.syntaxes.length).to eq 1
    syntax = playbook.syntaxes.first
    expect(syntax.verb).to eq :verb
  end

  it 'runs before_action hooks' do
    playbook.before_action do |action|
      action.actor[:executed] = true
    end

    playbook.respond_with Gamefic::Response.new(:command) {}

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it 'cancels actions from before_action hooks' do
    actor[:executed] = false

    playbook.before_action do |action|
      action.cancel
    end

    playbook.respond_with(Gamefic::Response.new(:command) do |actor|
      actor[:executed] = true
    end)

    actor.perform 'command'
    expect(actor[:executed]).to be(false)
  end

  it 'runs after_action hooks' do
    playbook.after_action do |action|
      action.actor[:executed] = true
    end

    playbook.respond_with Gamefic::Response.new(:command) {}

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it "dispatches the most recently declared action first" do
    num = 0
    playbook.respond_with(Gamefic::Response.new(:command) do
      num = 1
    end)
    playbook.respond_with(Gamefic::Response.new(:command) do
      num = 2
    end)
    playbook.respond_with(Gamefic::Response.new(:dummy, Gamefic::Query::Text.new) do
      # noop
    end)
    playbook.respond_with(Gamefic::Response.new(:command) do
      num = 3
    end)
    actor.perform 'command'
    expect(num).to eq(3)
  end

  it "returns all actions independently of verbs" do
    playbook.respond_with Gamefic::Response.new(:action1) {}
    playbook.respond_with Gamefic::Response.new(:action2) {}
    expect(playbook.responses.length).to eq(2)
  end

  it 'skips duplicate syntaxes' do
    playbook.respond_with Gamefic::Response.new(:make, Gamefic::Query::Scoped.new(Gamefic::Scope::Family)) { |_, _, _| }
    # Making the action creates a default syntax `make :var1 :var2`
    expect(playbook.syntaxes.length).to eq(1)
    playbook.interpret_with Gamefic::Syntax.new('make :a from :b', 'make :a :b')
    playbook.interpret_with Gamefic::Syntax.new('make :x from :y', 'make :x :y')
    # The above syntaxes are equivalent, so the second is ignored
    expect(playbook.syntaxes.length).to eq(2)
  end

  describe '#respond' do
    it 'adds a response' do
      response = playbook.respond_with Gamefic::Response.new(:verb) { |actor| actor }
      expect(response).to be_a(Gamefic::Response)
      expect(playbook.responses).to eq([response])
    end

    it 'adds a default syntax' do
      playbook.respond_with Gamefic::Response.new(:verb) { |actor| actor }
      expect(playbook.syntaxes).to be_one
      expect(playbook.syntaxes.first.verb).to be(:verb)
    end

    it 'sorts by precision' do
      high = playbook.respond_with Gamefic::Response.new(:verb, Gamefic::Query::Scoped.new(Gamefic::Scope::Family, Gamefic::Active)) { |*args| nil }
      low = playbook.respond_with Gamefic::Response.new(:verb, Gamefic::Query::Text.new) { |*args| nil }
      responses = playbook.responses_for(:verb)
      expect(responses).to eq([high, low])
    end
  end

  describe '#interpret' do
    it 'adds a syntax' do
      playbook.respond_with Gamefic::Response.new(:look) { |_| nil }
      syntax = playbook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      expect(syntax).to be_a(Gamefic::Syntax)
      expect(playbook.syntaxes_for(:examine)).to eq([syntax])
    end

    it 'sorts by token count' do
      playbook.respond_with Gamefic::Response.new(:look) { |_| nil }
      high = playbook.interpret_with Gamefic::Syntax.new('examine :thing inside :container', 'look :thing :container')
      low = playbook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      expect(playbook.syntaxes_for(:examine)).to eq([high, low])
    end
  end

  describe '#responses_for' do
    it 'returns responses for matching verbs' do
      match = playbook.respond_with Gamefic::Response.new(:verb) { |actor| actor }
      playbook.respond_with Gamefic::Response.new(:other) { |actor| actor }
      matches = playbook.responses_for(:verb)
      expect(matches).to eq([match])
    end

    it 'returns responses for multiple verbs' do
      match1 = playbook.respond_with Gamefic::Response.new(:verb) { |actor| actor }
      match2 = playbook.respond_with Gamefic::Response.new(:other) { |actor| actor }
      matches = playbook.responses_for(:verb, :other)
      expect(matches).to eq([match1, match2])
    end
  end

  describe '#syntaxes_for' do
    it 'returns syntaxes for matching synonyms' do
      playbook.respond_with Gamefic::Response.new(:look) { |_| nil }
      match = playbook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      matches = playbook.syntaxes_for(:examine)
      expect(matches).to eq([match])
    end

    it 'returns responses for multiple synonyms' do
      match1 = playbook.respond_with Gamefic::Response.new(:verb) { |actor| actor }
      match2 = playbook.respond_with Gamefic::Response.new(:other) { |actor| actor }
      matches = playbook.responses_for(:verb, :other)
      expect(matches).to eq([match1, match2])
    end
  end

  describe '#verbs' do
    it 'returns verbs without synonyms' do
      playbook.respond_with Gamefic::Response.new(:verb) { |_| nil }
      playbook.interpret_with Gamefic::Syntax.new('synonym', 'verb')
      expect(playbook.verbs).to eq([:verb])
    end
  end

  describe '#synonyms' do
    it 'returns verbs and synonyms' do
      playbook.respond_with Gamefic::Response.new (:verb) { |_| nil }
      playbook.interpret_with Gamefic::Syntax.new('synonym', 'verb')
      expect(playbook.synonyms).to eq([:synonym, :verb])
    end
  end
end
