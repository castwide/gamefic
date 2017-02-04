require 'gamefic-sdk'

describe "Cloak of Darkness" do
  it "concludes with test me" do
    plot = Plot.new(Source::File.new('examples/cloak_of_darkness/scripts', Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'main'
    character = plot.make Character, :name => 'player'
    plot.introduce character
    character.perform "test me"
    character.queue.length.times do |actor|
      plot.ready
      plot.update
    end
    expect(character.scene.kind_of?(Scene::Conclusion)).to be true
  end
end
