describe Gamefic::Scene::YesOrNo do
  before :each do
    @plot = Gamefic::Plot.new
    c = Class.new(Gamefic::Entity) { include Gamefic::Active }
    @character = @plot.make c, :name => 'character'
    @character[:answered] = nil
    @scene = @plot.yes_or_no "Yes or no?" do |actor, scene|
      actor[:answered] = scene.yes? ? 'yes' : 'no'
      # @todo Can yes_or_no proceed to default_scene automatically if no other
      #   scene is specified?
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
      expect(@character.scene.class).to eq(@plot.default_scene)
    }
  end

  it "detects no and advances to next scene" do
    ['no', 'No', 'NO', 'nope', 'n'].each { |answer|
      @character.cue @scene
      @character.queue.push answer
      @plot.update
      expect(@character[:answered]).to eq("no")
      expect(@character.scene.class).to eq(@plot.default_scene)
    }
  end

  it "detects invalid answer and stays in current scene" do
    @character.cue @scene
    @character.queue.push "undecided"
    @plot.update
    expect(@character[:answered]).to eq(nil)
    expect(@character.scene.class).to eq(@scene)
  end
end
