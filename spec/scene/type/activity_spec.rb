describe Gamefic::Scene::Type::Activity do
  it 'performs a command' do
    type = Gamefic::Scene::Type::Activity.new
    actor = Gamefic::Actor.new
    playbook = Gamefic::World::Playbook.new
    playbook.respond(:command) { |actor| actor[:executed] = true }
    actor.playbooks.push playbook
    actor.queue.push 'command'
    type.finish(actor)
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
