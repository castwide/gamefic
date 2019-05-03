describe Gamefic::Query::Text do
  it 'resolves greedy regular expression matches' do
    query = Gamefic::Query::Text.new(/foo/)
    matches = query.resolve(nil, 'foo')
    expect(matches.objects).to eq(['foo'])
    expect(matches.matching).to eq('foo')
    expect(matches.remaining).to eq('')
  end

  it 'rejects greedy regular expression mismatches' do
    query = Gamefic::Query::Text.new(/foo/)
    matches = query.resolve(nil, 'bar')
    expect(matches.objects).to be_empty
    expect(matches.matching).to be_empty
    expect(matches.remaining).to eq('bar')
  end

  it 'resolves partial regular expression matches' do
    query = Gamefic::Query::Text.new(/foo/)
    matches = query.resolve(nil, 'foo bar')
    expect(matches.objects).to eq(['foo bar'])
    expect(matches.matching).to eq('foo bar')
    expect(matches.remaining).to eq('')
  end

  it 'resolves exact regular expression matches' do
    query = Gamefic::Query::Text.new(/^foo$/)
    matches = query.resolve(nil, 'foo')
    expect(matches.objects).to eq(['foo'])
    expect(matches.matching).to eq('foo')
    expect(matches.remaining).to be_empty
  end

  it 'rejects exact regular expression mismatches' do
    query = Gamefic::Query::Text.new(/^foo$/)
    matches = query.resolve(nil, 'foo bar')
    expect(matches.objects).to be_empty
    expect(matches.matching).to be_empty
    expect(matches.remaining).to eq('foo bar')
  end

  it 'resolves variable regular expression matches' do
    query = Gamefic::Query::Text.new(/(foo|bar)/)
    matches = query.resolve(nil, 'bar')
    expect(matches.objects).to eq(['bar'])
    expect(matches.matching).to eq('bar')
    expect(matches.remaining).to be_empty
  end

  it 'resolves variable regular expression multiple matches' do
    query = Gamefic::Query::Text.new(/(foo|bar)/)
    matches = query.resolve(nil, 'foo bar baz')
    expect(matches.objects).to eq(['foo bar baz'])
    expect(matches.matching).to eq('foo bar baz')
    expect(matches.remaining).to be_empty
  end

  it 'resolves exact variable regular expression multiple matches' do
    query = Gamefic::Query::Text.new(/^(foo|bar)$/)
    matches = query.resolve(nil, 'foo')
    expect(matches.objects).to eq(['foo'])
    expect(matches.matching).to eq('foo')
    expect(matches.remaining).to be_empty
  end

  it 'rejects exact variable regular expression multiple misatches' do
    query = Gamefic::Query::Text.new(/^(foo|bar)$/)
    matches = query.resolve(nil, 'foo bar')
    expect(matches.objects).to be_empty
    expect(matches.matching).to be_empty
    expect(matches.remaining).to eq('foo bar')
  end
end
