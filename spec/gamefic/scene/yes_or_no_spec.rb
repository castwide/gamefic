describe Scene::YesOrNo do
  before :each do
    @plot = Plot.new
    @character = @plot.make Character, :name => 'character'
    @character[:answered] = nil
    @scene = @plot.yes_or_no "Yes or no?" do |actor, data|
      actor[:answered] = data.yes? ? 'yes' : 'no'
      actor.cue @plot.default_scene
    end
    @plot.introduce @character
  end
  it "detects yes and advances to next scene" do
    ['yes', 'Yes', 'YES', 'yeah', 'y'].each { |answer|
      @character.cue @scene
      @character.queue.push answer
      @plot.update
      expect(@character[:answered]).to eq("yes")
      expect(@character.scene).to eq(@plot.default_scene)
    }
  end
  it "detects no and advances to next scene" do
    ['no', 'No', 'NO', 'nope', 'n'].each { |answer|
      @character.cue @scene
      @character.queue.push answer
      @plot.update
      expect(@character[:answered]).to eq("no")
      expect(@character.scene).to eq(@plot.default_scene)
    }
  end
  it "detects invalid answer and stays in current scene" do
    @character.cue @scene
    @character.queue.push "undecided"
    @plot.update
    expect(@character[:answered]).to eq(nil)
    expect(@character.scene).to eq(@scene)
  end
end
