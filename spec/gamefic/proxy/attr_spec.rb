# frozen_string_literal: true

RSpec.describe Gamefic::Proxy::Attr do
  it 'fetches an attribute' do
    struct = OpenStruct.new(thing: Gamefic::Entity.new)
    proxy = Gamefic::Proxy::Attr.new(:thing)
    expect(proxy.fetch(struct)).to be(struct.thing)
  end
end
