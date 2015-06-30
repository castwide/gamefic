describe "Quit Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
    @character = @plot.make Character, :name => 'character'
    @plot.introduce @character
  end
  it "quits on yes" do
    @character.perform "quit"
    @character.update
    expect(@character.scene.key).to eq(:confirm_quit)
    @character.queue.push "yes"
    @character.update
    expect(@character.scene.key).to eq(:concluded)
  end
  it "cancels quit on no" do
    @character.perform "quit"
    @character.update
    expect(@character.scene.key).to eq(:confirm_quit)
    @character.queue.push "no"
    @character.update
    expect(@character.scene.key).to eq(:active)
  end
end
