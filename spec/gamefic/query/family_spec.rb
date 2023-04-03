describe Gamefic::Query::Family do
  it 'finds sibling entities' do
    parent = Gamefic::Entity.new
    entity = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    query = Gamefic::Query::Family.new
    result = query.context_from(entity)
    expect(result).to eq([sibling])
    expect(query.include?(entity, sibling)).to be(true)
  end

  it 'finds child entities' do
    entity = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: entity
    query = Gamefic::Query::Family.new
    result = query.context_from(entity)
    expect(result).to eq([child])
    expect(query.include?(entity, child)).to be(true)
  end

  it 'does not include the subject' do
    entity = Gamefic::Entity.new
    query = Gamefic::Query::Family.new
    result = query.context_from(entity)
    expect(result).to be_empty
    expect(query.include?(entity, subject)).to be(false)
  end
end
