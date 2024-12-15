# frozen_string_literal: true

describe Gamefic::Query::Text do
  it 'matches without arguments' do
    querydef = Gamefic::Query::Text.new
    result = querydef.filter(nil, 'anything')
    expect(result.match).to eq('anything')
  end

  it 'returns matched expressions' do
    querydef = Gamefic::Query::Text.new(/result/)
    result = querydef.filter(nil, 'result')
    expect(result.match).to eq('result')
  end

  it 'returns matched strings' do
    querydef = Gamefic::Query::Text.new('result')
    result = querydef.filter(nil, 'result')
    expect(result.match).to eq('result')
  end

  it 'rejects unmatched strings' do
    querydef = Gamefic::Query::Text.new('right')
    result = querydef.filter(nil, 'wrong')
    expect(result.match).to be_nil
  end

  it 'rejects unmatched partial strings' do
    querydef = Gamefic::Query::Text.new('right')
    result = querydef.filter(nil, 'rig')
    expect(result.match).to be_nil
  end

  it 'rejects unmatched expressions' do
    querydef = Gamefic::Query::Text.new(/right/)
    result = querydef.filter(nil, 'wrong')
    expect(result.match).to be_nil
  end

  it 'accepts matching tokens' do
    querydef = Gamefic::Query::Text.new
    expect(querydef.accept?(nil, 'something')).to be(true)
  end

  it 'rejects non-string tokens' do
    querydef = Gamefic::Query::Text.new
    entity = Gamefic::Entity.new
    expect(querydef.accept?(nil, entity)).to be(false)
  end

  it 'raises errors for invalid arguments' do
    expect { Gamefic::Query::Text.new(Object.new) }.to raise_error(ArgumentError)
  end
end
