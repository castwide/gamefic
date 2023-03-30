describe Gamefic::Scene::Type::MultipleChoice do
  it 'initializes MultipleChoice props' do
    type = Gamefic::Scene::Type::MultipleChoice.new
    expect(type.props).to be_a(Gamefic::Scene::Props::MultipleChoice)
  end
end
