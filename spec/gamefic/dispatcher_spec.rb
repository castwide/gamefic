describe Gamefic::Dispatcher do
  let(:stage_func) { Object.new }

  it 'filters and orders actions' do
    rulebook = Gamefic::Rulebook.new(stage_func)
    response1 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    response2 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    actor = Gamefic::Actor.new
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    dispatcher = Gamefic::Dispatcher.dispatch(actor, 'command')
    expect(dispatcher.proceed.response).to be(response2)
    expect(dispatcher.proceed.response).to be(response1)
    expect(dispatcher.proceed).to be_nil
  end
end
