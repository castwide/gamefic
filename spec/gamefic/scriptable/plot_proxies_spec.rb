# frozen_string_literal: true

describe Gamefic::Scriptable::PlotProxies do
  let(:klass) do
    Class.new do
      extend Gamefic::Scriptable::PlotProxies

      attr_reader :plot

      def initialize plot
        @plot = plot
      end
    end
  end

  it 'picks from plots' do
    plot = Gamefic::Plot.new
    entity = plot.make(Gamefic::Entity, name: 'thing')
    proxy = klass.plot_pick('thing')
    object = klass.new(plot)
    expect(proxy.fetch(object)).to be(entity)
  end
end
