describe Action do
  it "assigns higher specificity to an action with more queries" do
    action1 = Action.new(:foo)
    action2 = Action.new(:foo, double)
    expect(action2.specificity > action1.specificity).to eq(true)
  end
  it "assigns lower specificity to a nil command" do
    action1 = Action.new(nil)
    action2 = Action.new(:foo)
    expect(action2.specificity > action1.specificity).to eq(true)  
  end
  it "accepts valid proc arity" do
    expect {
      Action.new :foo do |arg1|
        # This proc should have one argument
      end
    }.to_not raise_error  
    expect {
      Action.new :foo, double do |arg1, arg2|
        # This proc should have two arguments
      end
    }.to_not raise_error
    expect {
      Action.new :foo, double, double do |arg1, *arg2|
        # Procs can use variable length arguments
      end
    }.to_not raise_error
  end
  it "raises an exception for invalid proc arity" do
    expect {
      Action.new :foo, double do |arg1|
        # This proc should have two arguments
      end
    }.to raise_error ActionArgumentError
  end
end
