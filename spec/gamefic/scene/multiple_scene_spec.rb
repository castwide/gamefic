describe Scene::MultipleScene do
  it "cues the selected scene" do
    plot = Plot.new
    character = plot.make Character
    scene1 = plot.pause :scene1
    scene2 = plot.pause :scene2
    chooser = plot.multiple_scene "one" => scene1, "two" => scene2
    plot.introduce character
    character.cue chooser
    character.queue.push "one"
    plot.ready
    plot.update
    expect(character.scene).to eq(scene1)
  end
end
