# frozen_string_literal: true

RSpec.describe Gamefic::Proxy::Config do
  it 'fetches an attribute' do
    hash = {
      thing: {
        name: 'thing name'
      }
    }
    object = OpenStruct.new(config: hash)
    proxy = Gamefic::Proxy::Config.new[:thing][:name]
    expect(proxy.fetch(object)).to eq(hash[:thing][:name])
  end
end
