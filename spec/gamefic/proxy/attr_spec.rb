# frozen_string_literal: true

RSpec.describe Gamefic::Proxy::Attr do
  it 'fetches an attribute' do
    struct = OpenStruct.new(thing: Gamefic::Entity.new)
    proxy = Gamefic::Proxy::Attr.new(:thing)
    expect(proxy.fetch(struct)).to be(struct.thing)
  end

  it 'chains attributes' do
    entity = Gamefic::Entity.new(name: 'thing name')
    object = Object.new
    object.define_singleton_method(:thing) { entity }
    proxy = Gamefic::Proxy::Attr.new(:thing, :name)
    expect(proxy.fetch(object)).to eq(object.thing.name)
  end
end
