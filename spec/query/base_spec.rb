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

  it 'finds nested objects' do
    query = Gamefic::Query::Base.new(Gamefic::Entity)
    parent = Gamefic::Entity.new name: 'parent'
    child = Gamefic::Entity.new name: 'child', parent: parent
    # HACK: Force context_from to use the test objects
    query.define_singleton_method :context_from do |_|
      [parent, child]
    end
    matches = query.resolve(nil, 'child in parent')
    expect(matches.objects).to eq([child])
  end

  it 'rejects improperly nested objects' do
    query = Gamefic::Query::Base.new(Gamefic::Entity)
    parent = Gamefic::Entity.new name: 'parent'
    child = Gamefic::Entity.new name: 'child', parent: parent
    # HACK: Force context_from to use the test objects
    query.define_singleton_method :context_from do |_|
      [parent, child]
    end
    matches = query.resolve(nil, 'parent in child')
    expect(matches.objects).to be_empty
  end
end
