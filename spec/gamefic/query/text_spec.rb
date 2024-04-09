# frozen_string_literal: true

describe Gamefic::Query::Text do
  it 'matches without arguments' do
    querydef = Gamefic::Query::Text.new
    result = querydef.query(nil, 'anything')
    expect(result.match).to eq('anything')
  end

  it 'returns matched expressions' do
    querydef = Gamefic::Query::Text.new(/result/)
    result = querydef.query(nil, 'result')
    expect(result.match).to eq('result')
  end

  it 'returns matched strings' do
    querydef = Gamefic::Query::Text.new('result')
    result = querydef.query(nil, 'result')
    expect(result.match).to eq('result')
  end

  it 'rejects unmatched strings' do
    querydef = Gamefic::Query::Text.new('right')
    result = querydef.query(nil, 'wrong')
    expect(result.match).to be_nil
  end

  it 'rejects unmatched partial strings' do
    querydef = Gamefic::Query::Text.new('right')
    result = querydef.query(nil, 'rig')
    expect(result.match).to be_nil
  end

  it 'rejects unmatched expressions' do
    querydef = Gamefic::Query::Text.new(/right/)
    result = querydef.query(nil, 'wrong')
    expect(result.match).to be_nil
  end

  it 'raises errors for invalid arguments' do
    expect { Gamefic::Query::Text.new({ bad: :arg }) }.to raise_error(ArgumentError)
  end
end
