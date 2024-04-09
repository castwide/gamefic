describe Gamefic::Props::Output do
  it 'freezes the data hash' do
    output = Gamefic::Props::Output.new.freeze
    expect { output[:messages] = 'test' }.to raise_error(FrozenError)
  end
end
