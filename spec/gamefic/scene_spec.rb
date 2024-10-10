# frozen_string_literal: true

describe Gamefic::Scene do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'executes start blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Default) do
      on_start { executed = true }
    end
    actor = Gamefic::Actor.new
    scene = klass.new(actor)
    scene.run_start_blocks
    expect(executed).to be(true)
  end

  it 'executes finish blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Default) do
      on_finish { executed = true }
    end
    actor = Gamefic::Actor.new
    scene = klass.new(actor)
    scene.run_finish_blocks
    expect(executed).to be(true)
  end
end
