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

  it 'delegates methods' do
    mod = Module.new do
      extend Gamefic::Scriptable
      delegate_method def my_method
        :ok
      end
    end
    Gamefic::Plot.delegate mod
    plot = Gamefic::Plot.new
    expect(plot.my_method).to be(:ok)
    expect(plot.stage { my_method }).to be(:ok)
  end
end
