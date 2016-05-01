describe "Quit Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.script 'standard'
    @character = @plot.make Character, :name => 'character'
    @plot.introduce @character
  end
  it "quits on yes" do
    @character.perform "quit"
    @character.update
    expect(@character.scene).to eq(:confirm_quit)
    @character.queue.push "yes"
    @plot.update
    expect(@character.scene).to eq(:concluded)
  end
  it "cancels quit on no" do
    @character.perform "quit"
    @character.update
    expect(@character.scene).to eq(:confirm_quit)
    @character.queue.push "no"
    @plot.update
    expect(@character.scene).to eq(:active)
  end
end
