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

  let(:narrator) { Gamefic::Narrator.new(plot) }

  it 'selects valid input' do
    actor.cue :active_choice
    narrator.start
    actor.queue.push 'one'
    narrator.finish
    expect(actor[:executed]).to eq('selection one')
  end

  it 'performs on invalid input' do
    actor.cue :active_choice
    narrator.start
    actor.queue.push 'command'
    narrator.finish
    expect(actor[:executed]).to eq('command')
  end

  it 'recues on invalid input' do
    scene = plot.named_scenes[:active_choice]
    scene.without_selection :recue
    actor.cue :active_choice
    narrator.start
    actor.queue.push 'command'
    narrator.finish
    narrator.start
    expect(actor.last_cue.key).to be(:active_choice)
  end

  it 'continues on invalid input' do
    scene = plot.named_scenes[:active_choice]
    scene.without_selection :continue
    actor.cue :active_choice
    narrator.start
    actor.queue.push 'command'
    narrator.finish
    narrator.start
    expect(actor.last_cue.key).to be(plot.default_scene)
  end
end
