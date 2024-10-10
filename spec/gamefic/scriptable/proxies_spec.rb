# frozen_string_literal: true

describe Gamefic::Scriptable::Proxies do
  let(:object) do
    klass = Class.new do
      include Gamefic::Scriptable::Proxies

      def proxyable
        'working'
      end
    end

    klass.new
  end

  it 'proxies' do
    agent = Gamefic::Proxy.new(:attr, :proxyable)
    unproxy = object.unproxy(agent)
    expect(unproxy).to be('working')
  end
end
