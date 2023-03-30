describe Gamefic::Take do
  it 'runs start blocks' do
    actor = Gamefic::Actor.new
    scene = Gamefic::Scene.new(:scene) do |scene|
      scene.on_start do |actor, _props|
        actor[:scene_started] = true
      end
    end
    take = Gamefic::Take.new(actor, scene)
    take.start
    expect(actor[:scene_started]).to be(true)
  end

  it 'runs finish blocks' do
    actor = Gamefic::Actor.new
    scene = Gamefic::Scene.new(:scene) do |scene|
      scene.on_finish do |actor, _props|
        actor[:scene_finished] = true
      end
    end
    take = Gamefic::Take.new(actor, scene)
    take.finish
    expect(actor[:scene_finished]).to be(true)
  end
end
