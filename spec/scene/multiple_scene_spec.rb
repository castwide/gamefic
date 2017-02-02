describe Scene::MultipleScene do
  it "cues the selected scene" do
    plot = Plot.new
    character = plot.make Character
    plot.pause :scene1
    plot.pause :scene2
    plot.multiple_scene :choose, "one" => :scene1, "two" => :scene2
    plot.introduce character
    character.cue :choose
    character.queue.push "one"
    plot.ready
    plot.update
    expect(character.scene).to eq(:scene1)
  end
end
