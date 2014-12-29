describe "Cloak of Darkness" do
  it "concludes with test me" do
    plot = Plot.new
    plot.load "examples/cloak_of_darkness/main.rb"
    plot.load "test.rb"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    expect(character.state.class).to eq(CharacterState::Concluded)
  end
end
