describe Gamefic::Action do
  it "assigns higher rank to an action with more queries" do
    action1 = Gamefic::Action.subclass(:foo)
    action2 = Gamefic::Action.subclass(:foo, Gamefic::Query::Base.new)
    expect(action2.rank > action1.rank).to eq(true)
  end

  it "assigns lower rank to a nil command" do
    action1 = Gamefic::Action.subclass(nil)
    action2 = Gamefic::Action.subclass(:foo)
    expect(action2.rank > action1.rank).to eq(true)  
  end

  it 'assigns higher rank to an action with a specific object' do
    entity = Gamefic::Entity.new
    general = Gamefic::Action.subclass(:command, Gamefic::Query::Base.new(Gamefic::Entity))
    specific = Gamefic::Action.subclass(:command, Gamefic::Query::Base.new(entity))
    expect(specific.rank).to be > general.rank
  end

  it "accepts valid proc arity" do
    expect {
      Gamefic::Action.subclass :foo do |arg1|
        # This proc should have one argument
      end
    }.to_not raise_error  
    expect {
      Gamefic::Action.subclass :foo, Gamefic::Query::Base.new do |arg1, arg2|
        # This proc should have two arguments
      end
    }.to_not raise_error
    expect {
      Gamefic::Action.subclass :foo, Gamefic::Query::Base.new, Gamefic::Query::Base.new do |arg1, *arg2|
        # Procs can use variable length arguments
      end
    }.to_not raise_error
  end

  it "raises an exception for invalid proc arity" do
    expect {
      Gamefic::Action.subclass :foo, Gamefic::Query::Base.new do |arg1|
        # This proc should have two arguments
      end
    }.to raise_error ArgumentError
  end

  it "marks actions executed" do
    klass = Gamefic::Action.subclass(:command) {}
    actor = Gamefic::Actor.new
    action = klass.new(actor, [])
    action.execute
    expect(action).to be_executed
  end

  it "validates matching arguments" do
    klass = Gamefic::Action.subclass(:command, Gamefic::Query::Text.new(/foo/)) {}
    actor = Gamefic::Actor.new
    expect(klass.valid?(actor, ['foo'])).to be(true)
  end

  it "invalidates non-matching arguments" do
    klass = Gamefic::Action.subclass(:command, Gamefic::Query::Text.new(/foo/)) {}
    actor = Gamefic::Actor.new
    expect(klass.valid?(actor, ['bar'])).to be(false)
  end

  it 'has a signature' do
    klass = Gamefic::Action.subclass(:command, Gamefic::Query::Text.new(/foo/)) {}
    expect(klass.signature).to start_with('command text')
  end

  it 'returns an Action instance for valid attempts' do
    klass = Gamefic::Action.subclass(:command, Gamefic::Query::Text.new(/foo/)) {}
    expect(klass.attempt(nil, Gamefic::Command.new(:command, ['foo']))).to be_a(klass)
  end

  it 'returns nil for invalid attempts' do
    klass = Gamefic::Action.subclass(:command, Gamefic::Query::Text.new(/foo/)) {}
    expect(klass.attempt(nil, Gamefic::Command.new(nil, ['bar']))).to be_nil
  end
end
