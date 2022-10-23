describe Gamefic::Query::External do
  it "finds objects by name" do
    b1 = Gamefic::Element.new name: 'fact'
    b2 = Gamefic::Element.new name: 'idea'
    query = Gamefic::Query::External.new([b1, b2])
    matches = query.resolve(nil, 'fact')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to be(b1)
    matches = query.resolve(nil, 'the fact')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to be(b1)
    matches = query.resolve(nil, 'a fact')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to be(b1)
  end

  it "finds objects by synonym" do
    b1 = Gamefic::Element.new name: 'fact', synonyms: 'truth'
    b2 = Gamefic::Element.new name: 'idea', synonyms: 'notion'
    query = Gamefic::Query::External.new([b1, b2])
    matches = query.resolve(nil, 'the truth')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to be(b1)
    matches = query.resolve(nil, 'a notion')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to be(b2)
  end

  it 'handles dynamic arrays' do
    first = Gamefic::Entity.new(name: 'first')
    second = Gamefic::Entity.new(name: 'second')
    entities = [first]
    query = Gamefic::Query::External.new(entities)

    matches = query.resolve(nil, 'first')
    expect(matches.objects).to eq([first])

    entities.push second
    matches = query.resolve(nil, 'second')
    expect(matches.objects).to eq([second])
  end
end
