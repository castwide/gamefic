# frozen_string_literal: true

describe Gamefic::Scene::Activity do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'performs a command' do
    actor = Gamefic::Actor.new
    type = Gamefic::Scene::Activity.new(actor)
    rulebook = Gamefic::Rulebook.new
    rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |actor| actor[:executed] = true }
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    actor.queue.push 'command'
    type.finish
    expect(actor.queue).to be_empty
    expect(type.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
