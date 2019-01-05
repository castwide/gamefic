describe Gamefic::Scene::Pause do
  it "changes the character's state after a response" do
    plot = Gamefic::Plot.new
    c = Class.new(Entity) { include Gamefic::Active }
    character = plot.make c
    character[:has_paused] = false
    paused = plot.pause do |actor|
      actor[:has_paused] = true
      # @todo Determine if the pause scene should go to the default scene if
      # another scene isn't prepared.
      actor.prepare plot.default_scene
    end
    plot.introduce character
    character.cue paused
    expect(character.scene.class).to eq(paused)
    character.queue.push ""
    plot.ready
    expect(character.scene.class).to eq(plot.default_scene)
    expect(character[:has_paused]).to eq(true)
  end
end
