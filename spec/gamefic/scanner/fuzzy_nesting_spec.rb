# frozen_string_literal: true

describe Gamefic::Scanner::FuzzyNesting do
  it 'finds children' do
    drawer = Gamefic::Entity.new(name: 'drawer')
    sock = Gamefic::Entity.new(name: 'sock', parent: drawer)
    Gamefic::Entity.new(name: 'thing', parent: drawer)

    result = Gamefic::Scanner::FuzzyNesting.scan([drawer], 'soc in dra')
    expect(result.matched).to eq([sock])
  end

  it 'finds grandchildren' do
    drawer = Gamefic::Entity.new(name: 'drawer')
    sock = Gamefic::Entity.new(name: 'sock', parent: drawer)
    coin = Gamefic::Entity.new(name: 'coin', parent: sock)

    result = Gamefic::Scanner::FuzzyNesting.scan([drawer], 'coi from soc in dra')
    expect(result.matched).to eq([coin])
  end
end
