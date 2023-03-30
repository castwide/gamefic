describe Gamefic::Scene::Type::YesOrNo do
  it 'initializes YesOrNo props' do
    type = Gamefic::Scene::Type::YesOrNo.new
    expect(type.props).to be_a(Gamefic::Scene::Props::YesOrNo)
  end
end
