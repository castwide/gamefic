require 'gamefic-sdk'

describe "Restaurant" do
  it "concludes with test me" do
    plot = Plot.new(Source.new('./import', Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.load "examples/restaurant/main.plot"
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
