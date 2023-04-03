describe Gamefic::Scene::Rig::Activity do
  it 'performs a command' do
    type = Gamefic::Scene::Rig::Activity.new(nil)
    actor = Gamefic::Actor.new
    playbook = Gamefic::Playbook.new
    playbook.respond(:command) { |actor| actor[:executed] = true }
    actor.playbooks.push playbook
    actor.queue.push 'command'
    type.finish(actor)
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
