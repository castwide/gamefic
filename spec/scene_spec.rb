describe SceneManager do
  it "yields itself" do
    yielded = nil
    manager = SceneManager.new do |this|
      yielded = this
    end
    expect(yielded).to eq(manager)
  end
  it "prepares a scene" do
    started = false
    finished = false
    manager = SceneManager.new do |this|
      this.start do
        started = true
      end
      this.finish do
        finished = true
      end
    end
    scene = manager.prepare :my_scene
    expect(scene.key).to be(:my_scene)
    scene.start nil
    expect(started).to be(true)
    scene.finish nil, nil
    expect(finished).to be(true)
  end
end
