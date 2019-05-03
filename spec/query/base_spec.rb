describe Gamefic::Query::Base do
  it 'rates object arguments with higher precision' do
    query1 = Gamefic::Query::Base.new(Gamefic::Entity.new)
    query2 = Gamefic::Query::Base.new(Gamefic::Entity)
    expect(query1.precision).to be > query2.precision
  end

  it 'accepts objects that match class arguments' do
    query = Gamefic::Query::Base.new(Gamefic::Entity)
    entity = Gamefic::Entity.new
    expect(query.accept?(entity)).to be(true)
  end

  it 'rejects objects that do not match class arguments' do
    query = Gamefic::Query::Base.new(Gamefic::Entity)
    hash = {}
    expect(query.accept?(hash)).to be(false)
  end

  it 'accepts objects that pass method calls' do
    query = Gamefic::Query::Base.new(Gamefic::Entity, :has_description?)
    entity = Gamefic::Entity.new name: 'thing', description: 'description'
    expect(query.accept?(entity)).to be(true)
  end

  it 'rejects objects that do not pass method calls' do
    query = Gamefic::Query::Base.new(Gamefic::Entity, :has_description?)
    entity = Gamefic::Entity.new
    expect(query.accept?(entity)).to be(false)
  end
end
