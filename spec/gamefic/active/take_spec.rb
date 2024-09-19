# frozen_string_literal: true

describe Gamefic::Active::Take do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'runs start blocks' do
    Gamefic::Plot.script do
      block :scene, Gamefic::Scene::Default do |scene|
        scene.on_start do |actor, _props|
          actor[:scene_started] = true
        end
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    cue = Gamefic::Active::Cue.new(:scene)
    take = Gamefic::Active::Take.new(actor, cue)
    take.start
    expect(actor[:scene_started]).to be(true)
  end

  it 'runs finish blocks' do
    Gamefic::Plot.script do
      block :scene, Gamefic::Scene::Default do |scene|
        scene.on_finish do |actor, _props|
          actor[:scene_finished] = true
        end
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    cue = Gamefic::Active::Cue.new(:scene)
    take = Gamefic::Active::Take.new(actor, cue)
    take.finish
    expect(actor[:scene_finished]).to be(true)
  end

  it 'performs actions in Activity scene types' do
    Gamefic::Narrative.script do
      respond(:command) { |actor| actor[:executed] = true }
      block :scene, Gamefic::Scene::Activity
    end
    actor = Gamefic::Actor.new
    narr = Gamefic::Narrative.new
    narr.cast actor
    cue = Gamefic::Active::Cue.new(:scene)
    take = Gamefic::Active::Take.new(actor, cue)
    take.start
    actor.queue.push 'command'
    take.finish
    expect(actor[:executed]).to be(true)
  end

  it 'adds context to props' do
    Gamefic::Plot.script do
      block :scene, Gamefic::Scene::Default do |scn|
        scn.on_start do |actor, props|
          actor.tell "You got extra #{props.context[:extra]}"
        end
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    cue = Gamefic::Active::Cue.new(:scene, extra: 'data from context')
    take = Gamefic::Active::Take.new(actor, cue)
    take.start
    expect(actor.messages).to include('You got extra data from context')
  end

  it 'adds options from MultipleChoice scenes' do
    Gamefic::Plot.script do
      block :scene, Gamefic::Scene::MultipleChoice do |scene|
        scene.on_start do |_actor, props|
          props.options.concat ['one', 'two']
        end
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    cue = Gamefic::Active::Cue.new(:scene)
    take = Gamefic::Active::Take.new(actor, cue)
    take.start
    expect(take.props.output[:options]).to eq(['one', 'two'])
  end
end
