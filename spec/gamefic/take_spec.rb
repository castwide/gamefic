describe Gamefic::Take do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'runs start blocks' do
    actor = Gamefic::Actor.new
    scene = Gamefic::Scene.new(:scene, stage_func) do |scene|
      scene.on_start do |actor, _props|
        actor[:scene_started] = true
      end
    end
    take = Gamefic::Take.new(actor, scene)
    take.start
    expect(actor[:scene_started]).to be(true)
  end

  it 'runs finish blocks' do
    actor = Gamefic::Actor.new
    scene = Gamefic::Scene.new(:scene, stage_func) do |scene|
      scene.on_finish do |actor, _props|
        actor[:scene_finished] = true
      end
    end
    take = Gamefic::Take.new(actor, scene)
    take.finish
    expect(actor[:scene_finished]).to be(true)
  end

  it 'performs actions in Activity scene types' do
    Gamefic::Narrative.script do
      respond(:command) { |actor| actor[:executed] = true }
      block :scene, rig: Gamefic::Rig::Activity
    end
    actor = Gamefic::Actor.new
    narr = Gamefic::Narrative.new
    narr.enter actor
    take = Gamefic::Take.new(actor, narr.rulebook.scenes[:scene])
    take.start
    actor.queue.push 'command'
    take.finish
    expect(actor[:executed]).to be(true)
  end

  it 'adds context to props' do
    scene = Gamefic::Scene.new(:scene, stage_func) do |scn|
      scn.on_start do |actor, props|
        actor.tell "You got extra #{props.context[:extra]}"
      end
    end
    actor = Gamefic::Actor.new
    take = Gamefic::Take.new(actor, scene, extra: 'data from context')
    take.start
    expect(take.output[:messages]).to include('You got extra data from context')
  end

  it 'adds scene data to output' do
    scene = Gamefic::Scene.new(:scene, stage_func)
    actor = Gamefic::Actor.new
    take = Gamefic::Take.new(actor, scene)
    expect(take.output[:scene][:name]).to eq(scene.name)
    expect(take.output[:scene][:type]).to eq(scene.type)
  end

  it 'adds options from MultipleChoice rigs' do
    scene = Gamefic::Scene.new(:scene, stage_func, rig: Gamefic::Rig::MultipleChoice) do |scene|
      scene.on_start do |actor, props|
        props.options.concat ['one', 'two']
      end
    end
    actor = Gamefic::Actor.new
    take = Gamefic::Take.new(actor, scene)
    take.start
    expect(take.output[:options]).to eq(['one', 'two'])
  end
end
