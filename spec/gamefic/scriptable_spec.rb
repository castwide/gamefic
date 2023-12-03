describe Gamefic::Scriptable do
  it 'imports scripts' do
    mod = Module.new
    mod.extend Gamefic::Scriptable
    mod.script do
      pause :extended_pause
    end
    Gamefic::Plot.import mod
    plot = Gamefic::Plot.new
    expect(plot.scenes).to include(:extended_pause)
  end
end
