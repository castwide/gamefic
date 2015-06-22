require 'gamefic-sdk'

describe "Restaurant" do
  it "concludes with test me" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.load "examples/restaurant/main.rb"
    plot.load "examples/restaurant/test.rb"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    expect(character.scene.state).to eq("Concluded")
  end
end
