describe "Use Action" do
  it "does not raise errors for valid commands" do
    plot = Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    room = plot.make Room, :name => 'room'
    tool = plot.make Item, :name => 'tool', :parent => room
    target = plot.make Item, :name => 'target', :parent => room
    character = plot.make Character, :name => 'character', :parent => room
    poss = plot.make Item, :name => 'possession', :parent => character
    expect {
      character.perform "use tool"
      character.perform "use tool on target"
      character.perform "use possession"
      character.perform "use possession on target"
      character.perform "use foo"
      character.perform "use foo on bar"
      character.perform "use tool on bar"
      character.perform "use possession on bar"
    }.not_to raise_error
  end
end
