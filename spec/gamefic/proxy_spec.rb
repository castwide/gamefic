describe Gamefic::Scriptable::Proxy do
  let(:plot) do
    klass = Class.new(Gamefic::Narrative) do
      attr_reader :foo

      seed { @foo = make Gamefic::Entity, name: 'foo' }
    end
    klass.new
  end

  it 'fetches from instance methods' do
    proxy = Gamefic::Proxy.new(:foo)
    object = proxy.fetch(plot)
    expect(object).to be(plot.foo)
  end

  it 'fetches from instance variables' do
    proxy = Gamefic::Proxy.new(:@foo)
    object = proxy.fetch(plot)
    expect(object).to be(plot.foo)
  end
end
