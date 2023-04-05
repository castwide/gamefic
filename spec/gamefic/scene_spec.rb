describe Gamefic::Scene do
  it 'accepts start blocks from params' do
    scene = Gamefic::Scene.new(on_start: -> { nil })
    expect(scene.start_blocks.first).to be_a(Proc)
  end

  it 'accepts finish blocks from params' do
    scene = Gamefic::Scene.new(on_finish: -> { nil })
    expect(scene.finish_blocks.first).to be_a(Proc)
  end

  it 'accepts start blocks from yielded blocks' do
    scene = Gamefic::Scene.new do |scn|
      scn.on_start { nil }
    end
    expect(scene.start_blocks.first).to be_a(Proc)
  end

  it 'accepts finish blocks from yielded blocks' do
    scene = Gamefic::Scene.new do |scn|
      scn.on_finish { nil }
    end
    expect(scene.finish_blocks.first).to be_a(Proc)
  end
end
