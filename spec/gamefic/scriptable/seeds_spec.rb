# frozen_string_literal: true

describe Gamefic::Scriptable::Seeds do
  it 'seeds a block' do
    klass = Class.new do
      extend Gamefic::Scriptable::Seeds
      seed {}
    end

    expect(klass.seeds).to be_one
  end

  it 'seeds methods by name' do
    klass = Class.new do
      extend Gamefic::Scriptable::Seeds
      def meth1; end
      def meth2; end
      seed :meth1, :meth2
    end

    expect(klass.seeds).to be_one
  end

  it 'seeds methods by def' do
    klass = Class.new do
      extend Gamefic::Scriptable::Seeds
      seed def meth1; end
    end

    expect(klass.seeds).to be_one
  end
end
