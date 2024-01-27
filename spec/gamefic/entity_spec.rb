describe Gamefic::Entity do
  it 'inspects the name' do
    entity = Gamefic::Entity.new(name: 'thing')
    expect(entity.inspect).to eq('#<Gamefic::Entity thing>')
  end
end
