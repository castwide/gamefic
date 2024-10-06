# frozen_string_literal: true

describe Gamefic::Query::General do
  let(:entities) {
    [
      Gamefic::Entity.new(name: 'one'),
      Gamefic::Entity.new(name: 'two')
    ]
  }

  describe '#query' do
    it 'returns match from array' do
      general = Gamefic::Query::General.new(entities)
      result = general.query(nil, 'one')
      expect(result.match).to eq(entities.first)
    end

    it 'returns nil for unmatched objects' do
      general = Gamefic::Query::General.new(entities)
      result = general.query(nil, 'three')
      expect(result.match).to be_nil
    end
  end

  describe '#select' do
    it 'returns initial array' do
      general = Gamefic::Query::General.new(entities)
      result = general.select(nil)
      expect(result).to eq(entities)
    end

    it 'filters initial array with proc argument' do
      general = Gamefic::Query::General.new(entities, ->(ent) { ent.name == 'two' })
      result = general.select(nil)
      expect(result).to eq([entities.last])
    end

    it 'filters string arguments' do
      general = Gamefic::Query::General.new(entities, 'one')
      result = general.select(nil)
      expect(result).to eq([entities.first])
    end
  end
end
