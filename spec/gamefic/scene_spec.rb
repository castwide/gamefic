# frozen_string_literal: true

describe Gamefic::Scene do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'executes start blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Base) do
      on_start { executed = true }
    end
    actor = Gamefic::Actor.new
    scene = klass.new(actor)
    scene.start
    expect(executed).to be(true)
  end

  it 'executes finish blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Base) do
      on_finish { executed = true }
    end
    actor = Gamefic::Actor.new
    scene = klass.new(actor)
    scene.finish
    expect(executed).to be(true)
  end
end
