# frozen_string_literal: true

describe Gamefic::Query::Integer do
  describe '#query' do
    it 'matches numeric strings' do
      querydef = Gamefic::Query::Integer.new
      result = querydef.filter(nil, '100')
      expect(result.match).to eq(100)
    end

    it 'matches integers' do
      querydef = Gamefic::Query::Integer.new
      result = querydef.filter(nil, 100)
      expect(result.match).to eq(100)
    end

    it 'rejects unmatched strings' do
      querydef = Gamefic::Query::Integer.new
      result = querydef.filter(nil, 'some')
      expect(result.match).to be_nil
    end
  end

  describe '#accept?' do
    it 'accepts integers' do
      querydef = Gamefic::Query::Integer.new
      expect(querydef.accept?(nil, 100)).to be(true)
    end
  end

  it 'passes integers to responses' do
    klass = Class.new(Gamefic::Plot) do
      respond(:set, integer) { |actor, number| actor[:hit_points] = number }
    end
    plot = klass.new
    player = plot.introduce
    player.perform 'set 100'
    expect(player[:hit_points]).to eq(100)
  end
end
