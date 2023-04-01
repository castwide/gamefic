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

  it 'performs actions in Activity scene types' do
    actor = Gamefic::Actor.new
    playbook = Gamefic::Playbook.new
    playbook.respond(:command) { |actor| actor[:executed] = true }
    actor.playbooks.push playbook
    scene = Gamefic::Scene.new(:activity, rig: Gamefic::Scene::Rig::Activity)
    take = Gamefic::Take.new(actor, scene)
    take.start
    actor.queue.push 'command'
    take.finish
    expect(actor[:executed]).to be(true)
  end
end
