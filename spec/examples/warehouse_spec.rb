require 'gamefic-sdk'

describe "Warehouse" do
  it "concludes with test me" do
    plot = Gamefic::Plot.new(Gamefic::Plot::Source.new('examples/warehouse/scripts', Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'main'
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    character.queue.length.times do |actor|
      plot.ready
      plot.update
    end
    expect(character.scene.type).to eq('Conclusion')
  end
end
