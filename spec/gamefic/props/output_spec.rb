describe Gamefic::Props::Output do
  it 'freezes the data hash' do
    output = Gamefic::Props::Output.new.freeze
    expect { output[:messages] = 'test' }.to raise_error(FrozenError)
  end

  it 'delegates writable methods' do
    output = Gamefic::Props::Output.new
    output.messages = 'my message'
    expect(output.messages).to eq('my message')
  end

  it 'raises missing methods' do
    output = Gamefic::Props::Output.new
    expect { output.queue = 'my message' }.to raise_error(NoMethodError)
  end
end
