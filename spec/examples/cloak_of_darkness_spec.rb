require 'gamefic-sdk'

describe "Cloak of Darkness" do
  it "concludes with test me" do
    plot = Plot.new(Source.new('./scripts', Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.load "examples/cloak_of_darkness/main.plot"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    100.times do
      plot.ready
      plot.update
    end
    expect(character.scene.state).to eq("Concluded")
  end
end
