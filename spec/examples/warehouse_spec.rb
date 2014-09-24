describe "Warehouse" do
  it "concludes with test me" do
    plot = Plot.new
    plot.load "examples/warehouse/main.rb"
    plot.load "examples/warehouse/test.rb"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    expect(character.state.class).to eq(CharacterState::Concluded)
  end
end
