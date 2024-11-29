# frozen_string_literal: true

RSpec.describe Gamefic::Scanner do
  it 'returns matching objects' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    objects = [one, two]
    token = 'one'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([one])
    expect(result.remainder).to eq('')
  end

  it 'returns empty result for unscaned tokens' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    objects = [one, two]
    token = 'three'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([])
    expect(result.remainder).to eq('three')
  end

  it 'returns matches with remainders' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    objects = [one, two]
    token = 'one three'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([one])
    expect(result.remainder).to eq('three')
  end

  it 'performs fuzzy matches' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    three = Gamefic::Entity.new name: 'three', parent: two
    objects = [one, two, three]
    token = 'thre'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([three])
    expect(result.remainder).to eq('')
  end

  it 'returns multiple results' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    three = Gamefic::Entity.new name: 'three'
    objects = [one, two, three]
    token = 't'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([two, three])
    expect(result.remainder).to eq('')
  end

  it 'denests references' do
    one = Gamefic::Entity.new name: 'one'
    two = Gamefic::Entity.new name: 'two'
    three = Gamefic::Entity.new name: 'three', parent: two
    objects = [one, two, three]
    token = 'three from two'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([three])
    expect(result.remainder).to eq('')
  end

  it 'handles unicode characters' do
    one = Gamefic::Entity.new name: 'ꩺ'
    two = Gamefic::Entity.new name: 'two'
    objects = [one, two]
    token = 'ꩺ'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([one])
    expect(result.remainder).to eq('')
  end
end
