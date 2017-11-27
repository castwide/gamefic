describe Scene::MultipleScene do
  it "prepares the selected scene" do
    plot = Plot.new
    c = Class.new(Entity) { include Active }
    character = plot.make c
    scene1 = plot.pause :scene1
    scene2 = plot.pause :scene2
    chooser = plot.multiple_scene "one" => scene1, "two" => scene2
    plot.introduce character
    character.cue chooser
    character.queue.push "one"
    plot.ready
    plot.update
    expect(character.will_cue? scene1).to be true
  end

  it "tracks entered selections" do
    actor = Gamefic::Actor.new
    klass1 = Scene::Base.subclass
    klass1.tracked = true
    klass2 = Scene::Base.subclass
    klass2.tracked = true
    selector = Gamefic::Scene::MultipleScene.subclass do |actor, scene|
      scene.map 'one', klass1
      scene.map 'two', klass2
    end
    scene1 = klass1.new(actor)
    scene1.start
    selobj = selector.new(actor)
    selobj.start
    expect(selobj.state[:entered]['one']).to be(true)
    expect(selobj.state[:entered]['two']).to be(false)
  end
end
