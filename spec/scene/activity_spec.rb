describe Gamefic::Scene::Activity do
  it 'executes an action' do
    actor = Gamefic::Actor.new
    actor.queue.push 'command'
    playbook = Gamefic::Plot::Playbook.new
    acted = false
    playbook.respond :command do
      acted = true
    end
    actor.playbooks.push playbook
    scene = Gamefic::Scene::Activity.new(actor)
    scene.start
    scene.update
    scene.finish
    expect(actor.queue).to be_empty
    expect(acted).to be(true)
  end
end
