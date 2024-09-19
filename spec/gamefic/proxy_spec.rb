# frozen_string_literal: true

describe Gamefic::Scriptable::Proxies do
  let(:plot) do
    klass = Class.new(Gamefic::Narrative) do
      attr_reader :foo

      seed { @foo = make Gamefic::Entity, name: 'foo' }
    end
    klass.new
  end

  it 'fetches from instance methods' do
    agent = Gamefic::Proxy.new(:attr, :foo)
    object = plot.unproxy(agent)
    expect(object).to be(plot.foo)
  end

  it 'fetches from instance variables' do
    agent = Gamefic::Proxy.new(:ivar, :@foo)
    object = plot.unproxy(agent)
    expect(object).to be(plot.foo)
  end

  it 'fetches from indexes' do
    agent = Gamefic::Proxy.new(:index, 0)
    object = plot.unproxy(agent)
    expect(object).to be(plot.foo)
  end

  it 'raises on invalid agent symbols' do
    agent = Gamefic::Proxy.new(:attr, :error)
    expect { plot.unproxy(agent) }.to raise_error(ArgumentError)
  end
end
