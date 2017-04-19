describe "Quit Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @character = @plot.make Character, :name => 'character'
    @plot.introduce @character
  end
  it "quits on yes" do
    @character.perform "quit"
    @character.update
    expect(@character.scene.class).to be(Scene::YesOrNo)
    @character.queue.push "yes"
    @plot.update
    expect(@character.scene.class).to be(Scene::Conclusion)
  end
  it "cancels quit on no" do
    @character.perform "quit"
    @character.update
    expect(@character.scene.class).to be(Scene::YesOrNo)
    @character.queue.push "no"
    @plot.update
    expect(@character.scene).to be(@plot.default_scene)
  end
end
