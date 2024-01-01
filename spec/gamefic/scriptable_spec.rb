describe Gamefic::Scriptable do
  let(:scriptable) { Module.new.extend(Gamefic::Scriptable) }

  it 'includes blocks' do
    scriptable.script do
      pause :extended_pause
    end
    klass = Class.new(Gamefic::Narrative)
    klass.include scriptable
    narr = klass.new
    expect(narr.scenes).to include(:extended_pause)
  end

  it 'makes attribute seeds' do
    scriptable.attr_seed(:foo) { make Gamefic::Entity, name: 'foo' }
    klass = Class.new(Gamefic::Narrative)
    klass.include scriptable
    narr = klass.new
    expect(narr.foo).to be_a(Gamefic::Entity)
  end

  it 'includes module blocks once' do
    # This test is necessary because Opal can duplicate included modules
    scriptable.script { @foo = Object.new }
    other = Module.new.extend(Gamefic::Scriptable)
    other.include scriptable
    klass = Class.new(Gamefic::Narrative)
    klass.include scriptable
    klass.include other
    expect(klass.included_blocks).to be_one
  end
end
