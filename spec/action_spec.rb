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
    }.to raise_error Gamefic::ActionArgumentError
  end
end
