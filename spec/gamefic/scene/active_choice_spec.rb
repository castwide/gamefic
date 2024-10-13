# frozen_string_literal: true

describe Gamefic::Scene::ActiveChoice do
  let(:klass) do
    Class.new(Gamefic::Plot) do
      active_choice :active_choice do |scene|
        scene.on_start do |_actor, props|
          props.options.push 'one', 'two'
        end
        scene.on_finish do |actor, props|
          actor[:executed] ||= "selection #{props.selection}"
        end
      end
      respond(:command) { |actor| actor[:executed] = 'command' }
    end
  end

  let(:plot) { klass.new }

  let(:actor) { plot.introduce }

  it 'selects valid input' do
    actor.cue :active_choice
    plot.ready
    actor.queue.push 'one'
    plot.update
    expect(actor[:executed]).to eq('selection one')
  end

  it 'cancels on invalid input' do
    actor.cue :active_choice
    plot.ready
    actor.queue.push 'command'
    plot.update
    expect(actor[:executed]).to eq('command')
  end
end
