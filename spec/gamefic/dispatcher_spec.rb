describe Gamefic::Dispatcher do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'filters and orders actions' do
    rulebook = Gamefic::Rulebook.new(stage_func)
    response1 = rulebook.respond_with Gamefic::Response.new(:command, stage_func) { |_| nil }
    response2 = rulebook.respond_with Gamefic::Response.new(:command, stage_func) { |_| nil }
    actor = Gamefic::Actor.new
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    dispatcher = Gamefic::Dispatcher.dispatch(actor, 'command')
    expect(dispatcher.proceed.response).to be(response2)
    expect(dispatcher.proceed.response).to be(response1)
    expect(dispatcher.proceed).to be_nil
  end
end
