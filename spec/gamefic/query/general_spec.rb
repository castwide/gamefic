describe Gamefic::Query::General do
  it 'returns match from array' do
    entities = ['one', 'two']
    general = Gamefic::Query::General.new(entities)
    result = general.query(nil, 'one')
    expect(result.match).to eq('one')
  end

  it 'returns nil for unmatched objects' do
    entities = ['one', 'two']
    general = Gamefic::Query::General.new(entities)
    result = general.query(nil, 'three')
    expect(result.match).to be_nil
  end
end
