describe Gamefic::Scriptable do
  it 'includes blocks' do
    mod = Module.new
    mod.extend Gamefic::Scriptable
    mod.script do
      pause :extended_pause
    end
    klass = Class.new(Gamefic::Narrative)
    klass.include mod
    narr = klass.new
    expect(narr.scenes).to include(:extended_pause)
  end

  it 'makes attribute seeds' do
    mod = Module.new
    mod.extend Gamefic::Scriptable
    mod.attr_seed(:foo) { make Gamefic::Entity, name: 'foo' }
    klass = Class.new(Gamefic::Narrative)
    klass.include mod
    narr = klass.new
    expect(narr.foo).to be_a(Gamefic::Entity)
  end
end
