describe Gamefic::Scene do
  let(:stage_func) { Gamefic::Narrative.new }

  it 'executes start blocks from params' do
    executed = false
    scene = Gamefic::Scene::Default.new(:scene, stage_func, on_start: ->(_, _) { executed = true })
    scene.run_start_blocks nil, nil
    expect(executed).to be(true)
  end

  it 'executes finish blocks from params' do
    executed = false
    scene = Gamefic::Scene::Default.new(:scene, stage_func, on_finish: ->(_, _) { executed = true })
    scene.run_finish_blocks nil, nil
    expect(executed).to be(true)
  end

  it 'executes start blocks from blocks' do
    executed = false
    scene = Gamefic::Scene::Default.new(:scene, stage_func) do |scene|
      scene.on_start { |_, _| executed = true }
    end
    scene.run_start_blocks nil, nil
    expect(executed).to be(true)
  end

  it 'executes finish blocks from blocks' do
    executed = false
    scene = Gamefic::Scene::Default.new(:scene, stage_func) do |scene|
      scene.on_finish { |_, _| executed = true }
    end
    scene.run_finish_blocks nil, nil
    expect(executed).to be(true)
  end
end
