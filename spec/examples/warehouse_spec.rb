require 'gamefic-sdk'

describe "Warehouse" do
  it "concludes with test me" do
    plot = Plot.new(Source::File.new('examples/warehouse/scripts', Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'main'
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
