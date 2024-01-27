# frozen_string_literal: true

describe Gamefic::Scriptable::Proxy do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) do
    klass = Class.new do
      include Gamefic::Scriptable::Proxy

      def proxyable
        'working'
      end
    end

    klass.new
  end

  it 'proxies' do
    agent = object.proxy(:proxyable)
    unproxy = object.unproxy(agent)
    expect(unproxy).to be('working')
  end
end
