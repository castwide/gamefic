describe YesOrNoScene do
  before :each do
    @plot = Plot.new
    @character = @plot.make Character, :name => 'character'
    @character[:answered] = nil
    @plot.yes_or_no :yes_or_no, "Yes or no?" do |actor, data|
      actor[:answered] = data.answer
    end
    @plot.introduce @character
  end
  it "detects yes and advances to next scene" do
    ['yes', 'Yes', 'YES', 'yeah', 'y'].each { |answer|
      @plot.cue @character, :yes_or_no
      @character.queue.push answer
      @character.update
      expect(@character[:answered]).to eq("yes")
      expect(@character.scene.key).to eq(:active)
    }
  end
  it "detects no and advances to next scene" do
    ['no', 'No', 'NO', 'nope', 'n'].each { |answer|
      @plot.cue @character, :yes_or_no
      @character.queue.push answer
      @character.update
      expect(@character[:answered]).to eq("no")
      expect(@character.scene.key).to eq(:active)
    }
  end
  it "detects invalid answer and stays in current scene" do
    @plot.cue @character, :yes_or_no
    @character.queue.push "undecided"
    @character.update
    expect(@character[:answered]).to eq(nil)
    expect(@character.scene.key).to eq(:yes_or_no)
  end
end