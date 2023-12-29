describe Gamefic::Rulebook do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:rulebook) { Gamefic::Rulebook.new(stage_func) }

  let(:actor) do
    Gamefic::Actor.new do |actor|
      actor.epic.add OpenStruct.new(rulebook: rulebook)
    end
  end

  it "creates an action" do
    rulebook.respond_with Gamefic::Response.new(:command, stage_func) {}
    expect(rulebook.responses.length).to eq(1)
    expect(rulebook.responses.first.verb).to eq(:command)
  end

  it "tracks verbs" do
    rulebook.respond_with Gamefic::Response.new(:command, stage_func) {}
    expect(rulebook.verbs).to eq([:command])
  end

  it "freezes responses" do
    rulebook.freeze
    expect {
      rulebook.respond_with Gamefic::Response.new(:command, stage_func) {}
    }.to raise_error(FrozenError)
  end

  it "freezes syntaxes" do
    rulebook.respond_with Gamefic::Response.new(:look, stage_func) { |_| nil }
    rulebook.freeze
    expect {
      rulebook.interpret_with Gamefic::Syntax.new('examine', 'look')
    }.to raise_error(FrozenError)
  end

  it 'freezes existing {verb: response} maps' do
    rulebook.respond_with Gamefic::Response.new(:look, stage_func) { |_| 0 }
    rulebook.freeze
    expect { rulebook.respond_with Gamefic::Response.new(:look, stage_func) {} }.to raise_error(FrozenError)
  end

  it 'freezes existing {synonym: syntax} maps' do
    rulebook.respond_with Gamefic::Response.new(:verb1, stage_func) { |_| 0 }
    rulebook.respond_with Gamefic::Response.new(:verb2, stage_func) { |_| 0 }
    rulebook.interpret_with Gamefic::Syntax.new('synonym', 'verb1')
    rulebook.freeze
    expect { rulebook.interpret_with Gamefic::Syntax.new('synonym', 'verb2') }.to raise_error(FrozenError)
  end

  it 'freezes before actions' do
    rulebook.freeze
    expect {
      rulebook.before_action { |_| nil }
    }.to raise_error(FrozenError)
  end

  it 'freezes after actions' do
    rulebook.freeze
    expect {
      rulebook.after_action { |_| nil }
    }.to raise_error(FrozenError)
  end

  it "requires a syntax's translation to exist'" do
    expect {
      rulebook.interpret_with Gamefic::Syntax.new('foo :thing', 'bar :thing')
    }.to raise_error(RuntimeError)
  end

  it "translates to existing verbs" do
    rulebook.respond_with Gamefic::Response.new(:bar, stage_func) {}
    rulebook.interpret_with Gamefic::Syntax.new("foo :thing", "bar :thing")
    expect(rulebook.syntaxes.length).to eq 2
  end

  it "generates default syntaxes" do
    rulebook.respond_with Gamefic::Response.new(:verb, stage_func) {}
    expect(rulebook.syntaxes.length).to eq 1
    syntax = rulebook.syntaxes.first
    expect(syntax.verb).to eq :verb
  end

  it 'runs before_action hooks' do
    rulebook.before_action do |action|
      action.actor[:executed] = true
    end

    rulebook.respond_with Gamefic::Response.new(:command, stage_func) {}

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it 'cancels actions from before_action hooks' do
    actor[:executed] = false

    rulebook.before_action do |action|
      action.cancel
    end

    rulebook.respond_with(Gamefic::Response.new(:command, stage_func) do |actor|
      actor[:executed] = true
    end)

    actor.perform 'command'
    expect(actor[:executed]).to be(false)
  end

  it 'runs after_action hooks' do
    rulebook.after_action do |action|
      action.actor[:executed] = true
    end

    rulebook.respond_with Gamefic::Response.new(:command, stage_func) {}

    actor.perform 'command'
    expect(actor[:executed]).to be(true)
  end

  it "dispatches the most recently declared action first" do
    num = 0
    rulebook.respond_with(Gamefic::Response.new(:command, stage_func) do
      num = 1
    end)
    rulebook.respond_with(Gamefic::Response.new(:command, stage_func) do
      num = 2
    end)
    rulebook.respond_with(Gamefic::Response.new(:dummy, stage_func, Gamefic::Query::Text.new) do
      # noop
    end)
    rulebook.respond_with(Gamefic::Response.new(:command, stage_func) do
      num = 3
    end)
    actor.perform 'command'
    expect(num).to eq(3)
  end

  it "returns all actions independently of verbs" do
    rulebook.respond_with Gamefic::Response.new(:action1, stage_func) {}
    rulebook.respond_with Gamefic::Response.new(:action2, stage_func) {}
    expect(rulebook.responses.length).to eq(2)
  end

  it 'skips duplicate syntaxes' do
    rulebook.respond_with Gamefic::Response.new(:make, stage_func, Gamefic::Query::Scoped.new(Gamefic::Scope::Family)) { |_, _, _| }
    # Making the action creates a default syntax `make :var1 :var2`
    expect(rulebook.syntaxes.length).to eq(1)
    rulebook.interpret_with Gamefic::Syntax.new('make :a from :b', 'make :a :b')
    rulebook.interpret_with Gamefic::Syntax.new('make :x from :y', 'make :x :y')
    # The above syntaxes are equivalent, so the second is ignored
    expect(rulebook.syntaxes.length).to eq(2)
  end

  describe '#respond' do
    it 'adds a response' do
      response = rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |actor| actor }
      expect(response).to be_a(Gamefic::Response)
      expect(rulebook.responses).to eq([response])
    end

    it 'adds a default syntax' do
      rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |actor| actor }
      expect(rulebook.syntaxes).to be_one
      expect(rulebook.syntaxes.first.verb).to be(:verb)
    end

    it 'sorts by precision' do
      high = rulebook.respond_with Gamefic::Response.new(:verb, stage_func, Gamefic::Query::Scoped.new(Gamefic::Scope::Family, Gamefic::Active)) { |*args| nil }
      low = rulebook.respond_with Gamefic::Response.new(:verb, stage_func, Gamefic::Query::Text.new) { |*args| nil }
      responses = rulebook.responses_for(:verb)
      expect(responses).to eq([high, low])
    end
  end

  describe '#interpret' do
    it 'adds a syntax' do
      rulebook.respond_with Gamefic::Response.new(:look, stage_func) { |_| nil }
      syntax = rulebook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      expect(syntax).to be_a(Gamefic::Syntax)
      expect(rulebook.syntaxes_for(:examine)).to eq([syntax])
    end

    it 'sorts by token count' do
      rulebook.respond_with Gamefic::Response.new(:look, stage_func) { |_| nil }
      high = rulebook.interpret_with Gamefic::Syntax.new('examine :thing inside :container', 'look :thing :container')
      low = rulebook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      expect(rulebook.syntaxes_for(:examine)).to eq([high, low])
    end
  end

  describe '#responses_for' do
    it 'returns responses for matching verbs' do
      match = rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |actor| actor }
      rulebook.respond_with Gamefic::Response.new(:other, stage_func) { |actor| actor }
      matches = rulebook.responses_for(:verb)
      expect(matches).to eq([match])
    end

    it 'returns responses for multiple verbs' do
      match1 = rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |actor| actor }
      match2 = rulebook.respond_with Gamefic::Response.new(:other, stage_func) { |actor| actor }
      matches = rulebook.responses_for(:verb, :other)
      expect(matches).to eq([match1, match2])
    end
  end

  describe '#syntaxes_for' do
    it 'returns syntaxes for matching synonyms' do
      rulebook.respond_with Gamefic::Response.new(:look, stage_func) { |_| nil }
      match = rulebook.interpret_with Gamefic::Syntax.new('examine :thing', 'look :thing')
      matches = rulebook.syntaxes_for(:examine)
      expect(matches).to eq([match])
    end

    it 'returns responses for multiple synonyms' do
      match1 = rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |actor| actor }
      match2 = rulebook.respond_with Gamefic::Response.new(:other, stage_func) { |actor| actor }
      matches = rulebook.responses_for(:verb, :other)
      expect(matches).to eq([match1, match2])
    end
  end

  describe '#verbs' do
    it 'returns verbs without synonyms' do
      rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |_| nil }
      rulebook.interpret_with Gamefic::Syntax.new('synonym', 'verb')
      expect(rulebook.verbs).to eq([:verb])
    end
  end

  describe '#synonyms' do
    it 'returns verbs and synonyms' do
      rulebook.respond_with Gamefic::Response.new(:verb, stage_func) { |_| nil }
      rulebook.interpret_with Gamefic::Syntax.new('synonym', 'verb')
      expect(rulebook.synonyms).to eq([:synonym, :verb])
    end
  end
end
