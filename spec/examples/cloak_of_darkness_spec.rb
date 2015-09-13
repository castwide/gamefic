require 'gamefic-sdk'

describe "Cloak of Darkness" do
  it "concludes with test me" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.load "examples/cloak_of_darkness/main.plot"
    plot.load "examples/cloak_of_darkness/test.plot"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    expect(character.scene.state).to eq("Concluded")
  end
end
