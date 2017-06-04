describe Gamefic::Plot::Scenes do
  it "initialized default scene to Activity" do
    plot = Gamefic::Plot.new
    expect(plot.default_scene.type).to eq('Activity')
  end
end
