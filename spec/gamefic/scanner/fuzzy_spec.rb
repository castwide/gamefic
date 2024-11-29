# frozen_string_literal: true

describe Gamefic::Scanner::Fuzzy do
  it 'handles unicode characters' do
    one = Gamefic::Entity.new name: 'ぇワ'
    two = Gamefic::Entity.new name: 'two'
    objects = [one, two]
    token = 'ぇ'
    result = Gamefic::Scanner::Fuzzy.scan(objects, token)
    expect(result.matched).to eq([one])
    expect(result.remainder).to eq('')
  end
end
