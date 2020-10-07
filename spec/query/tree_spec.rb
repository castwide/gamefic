describe Gamefic::Query::Tree do
  it 'finds ancestors' do
    grandparent = Gamefic::Entity.new
    parent = Gamefic::Entity.new parent: grandparent
    subject = Gamefic::Entity.new parent: parent
    query = Gamefic::Query::Tree.new
    result = query.context_from(subject)
    expect(result).to eq([grandparent, parent])
  end
end
