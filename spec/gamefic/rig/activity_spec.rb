describe Gamefic::Rig::Activity do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'performs a command' do
    type = Gamefic::Rig::Activity.new(nil)
    actor = Gamefic::Actor.new
    rulebook = Gamefic::Rulebook.new(stage_func)
    rulebook.respond_with Gamefic::Response.new(:command, stage_func) { |actor| actor[:executed] = true }
    actor.rulebooks.add rulebook
    actor.queue.push 'command'
    type.finish(actor)
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
