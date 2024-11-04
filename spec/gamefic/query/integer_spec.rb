# frozen_string_literal: true

describe Gamefic::Query::Integer do
  it 'matches numeric strings' do
    querydef = Gamefic::Query::Integer.new
    result = querydef.query(nil, '100')
    expect(result.match).to eq(100)
  end

  it 'matches integers' do
    querydef = Gamefic::Query::Integer.new
    result = querydef.query(nil, 100)
    expect(result.match).to eq(100)
  end

  it 'rejects unmatched strings' do
    querydef = Gamefic::Query::Integer.new
    result = querydef.query(nil, 'some')
    expect(result.match).to be_nil
  end
end
