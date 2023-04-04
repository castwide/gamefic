# frozen_string_literal: true

describe Gamefic::Scripting do
  let(:klass) do
    klass = Class.new do
      include Gamefic::Scripting
      extend Gamefic::Scripting::ClassMethods
    end
  end

  it 'accepts scripts' do
    klass.script { nil }
    expect(klass.blocks).to be_one
  end

  it 'runs stages' do
    object = klass.new
    executed = object.stage { true }
    expect(executed).to be(true)
  end

  it 'runs scripts' do
    executed = false
    klass.script { executed = true }
    object = klass.new
    object.run_scripts
    expect(executed).to be(true)
  end
end
