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

  it 'handles plots and subplots' do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity, name: 'entity 1'
    subplot_klass = Class.new(Gamefic::Subplot) do
      script do
        make Gamefic::Entity, name: 'entity 2'
      end
    end

    player = plot.make_player_character
    plot.introduce player
    subplot = plot.branch subplot_klass, introduce: player
    query = Gamefic::Query::External.new(plot)

    context = query.context_from(player)
    expect(context.length).to eq(3)

    matches1 = query.resolve(player, 'entity 1')
    expect(matches1.objects).to eq([plot.pick('entity 1')])

    matches2 = query.resolve(player, 'entity 2')
    expect(matches2.objects).to eq([subplot.pick('entity 2')])
  end
end
