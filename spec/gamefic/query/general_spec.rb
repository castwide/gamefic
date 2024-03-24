describe Gamefic::Query::General do
  describe '#query' do
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

    it 'accepts procs' do
      prc = proc { ['one', 'two']}
      general = Gamefic::Query::General.new(prc)
      result = general.query(nil, 'one')
      expect(result.match).to eq('one')
    end

    it 'accepts procs with an argument' do
      subject = []
      prc = proc { |subj| subj + ['one'] }
      general = Gamefic::Query::General.new(prc)
      result = general.query(subject, 'one')
      expect(result.match).to eq('one')
    end
  end

  describe '#select' do
    it 'returns initial array' do
      entities = ['one', 'two']
      general = Gamefic::Query::General.new(entities)
      result = general.select(nil)
      expect(result).to eq(['one', 'two'])
    end

    it 'filters initial array with proc argument' do
      entities = ['one', 'two']
      general = Gamefic::Query::General.new(entities, ->(str) { str == 'two' })
      result = general.select(nil)
      expect(result).to eq(['two'])
    end
  end
end
