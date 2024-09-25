# frozen_string_literal: true

describe Gamefic::Scanner::Nesting do
  it 'finds children' do
    drawer = Gamefic::Entity.new(name: 'drawer')
    sock = Gamefic::Entity.new(name: 'sock', parent: drawer)
    Gamefic::Entity.new(name: 'thing', parent: drawer)

    result = Gamefic::Scanner::Nesting.scan([drawer, sock], 'sock in drawer')
    expect(result.matched).to eq([sock])
  end

  it 'finds grandchildren' do
    drawer = Gamefic::Entity.new(name: 'drawer')
    sock = Gamefic::Entity.new(name: 'sock', parent: drawer)
    coin = Gamefic::Entity.new(name: 'coin', parent: sock)

    result = Gamefic::Scanner::Nesting.scan([drawer, sock, coin], 'coin from sock in drawer')
    expect(result.matched).to eq([coin])
  end
end
