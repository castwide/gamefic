# frozen_string_literal: true

describe Gamefic::Scene::Activity do
  let(:klass) do
    Class.new(Gamefic::Narrative) do
      respond(:command) { |actor| actor[:executed] = true}
    end
  end

  let(:plot) { klass.new }

  it 'performs a command' do
    actor = plot.introduce
    activity = Gamefic::Scene::Activity.new(actor)
    actor.queue.push 'command'
    activity.prepare_and_finish
    expect(actor.queue).to be_empty
    expect(activity.props.input).to eq('command')
    expect(actor[:executed]).to be(true)
  end
end
