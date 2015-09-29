require 'gamefic-sdk'

describe "Warehouse" do
  it "concludes with test me" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.load "examples/warehouse/main.plot"
    plot.load "examples/warehouse/test.plot"
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    100.times do
      plot.update
    end
    expect(character.scene.state).to eq("Concluded")
  end
end
