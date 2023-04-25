describe Gamefic::Scenebook do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'adds a scene' do
    scenebook = Gamefic::Scenebook.new
    scene = Gamefic::Scene.new(:scene, stage_func)
    scenebook.add scene
    expect(scenebook.scenes).to eq([scene])
  end
end
