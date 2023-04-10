describe Gamefic::Dispatcher do
  it 'filters and orders actions' do
    playbook = Gamefic::Playbook.new
    response1 = playbook.respond_with Gamefic::Response.new(:command) { |_| nil }
    response2 = playbook.respond_with Gamefic::Response.new(:command) { |_| nil }
    actor = Gamefic::Actor.new
    actor.playbooks.add playbook
    dispatcher = Gamefic::Dispatcher.dispatch(actor, 'command')
    expect(dispatcher.next.response).to be(response2)
    expect(dispatcher.next.response).to be(response1)
    expect(dispatcher.next).to be_nil
  end
end
