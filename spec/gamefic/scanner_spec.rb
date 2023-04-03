RSpec.describe Gamefic::Scanner do
  it 'returns matching objects' do
    objects = ['one', 'two']
    token = 'one'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq(['one'])
    expect(result.remainder).to eq('')
  end

  it 'returns empty result for unscaned tokens' do
    objects = ['one', 'two']
    token = 'three'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq([])
    expect(result.remainder).to eq('three')
  end

  it 'returns matches with remainders' do
    objects = ['one', 'two']
    token = 'one three'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq(['one'])
    expect(result.remainder).to eq('three')
  end

  it 'performs fuzzy matches' do
    objects = ['one', 'two', 'three']
    token = 'thre'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq(['three'])
    expect(result.remainder).to eq('')
  end

  it 'returns multiple results' do
    objects = ['one', 'two', 'three']
    token = 't'
    result = Gamefic::Scanner.scan(objects, token)
    expect(result.matched).to eq(['two', 'three'])
    expect(result.remainder).to eq('')
  end
end
