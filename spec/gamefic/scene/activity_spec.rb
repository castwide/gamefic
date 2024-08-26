# frozen_string_literal: true

describe Gamefic::Scene::Activity do
  let(:stage_func) { Object.new }

  it 'performs a command' do
    type = Gamefic::Scene::Activity.new(nil, nil)
    actor = Gamefic::Actor.new
    rulebook = Gamefic::Rulebook.new
    rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |actor| actor[:executed] = true }
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    actor.queue.push 'command'
    props = type.new_props
    type.finish(actor, props)
    expect(actor.queue).to be_empty
    expect(props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
