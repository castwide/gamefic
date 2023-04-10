describe Gamefic::Rig::Activity do
  it 'performs a command' do
    type = Gamefic::Rig::Activity.new(nil)
    actor = Gamefic::Actor.new
    playbook = Gamefic::Playbook.new
    playbook.respond_with Gamefic::Response.new(:command) { |actor| actor[:executed] = true }
    actor.playbooks.add playbook
    actor.queue.push 'command'
    type.finish(actor)
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
