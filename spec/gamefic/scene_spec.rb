# frozen_string_literal: true

describe Gamefic::Scene do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'executes start blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Default) do
      on_start { executed = true }
    end
    scene = klass.new(nil)
    scene.run_start_blocks nil, nil
    expect(executed).to be(true)
  end

  it 'executes finish blocks from blocks' do
    executed = false
    klass = Class.new(Gamefic::Scene::Default) do
      on_finish { executed = true }
    end
    scene = klass.new(nil)
    scene.run_finish_blocks nil, nil
    expect(executed).to be(true)
  end
end
