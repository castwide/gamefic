# frozen_string_literal: true

describe Gamefic::Props::Output do
  it 'delegates readable methods' do
    output = Gamefic::Props::Output.new
    Gamefic::Props::Output::READER_METHODS.each do |mthd|
      expect { output.send(mthd) }.not_to raise_error
    end
  end

  it 'delegates writable methods' do
    output = Gamefic::Props::Output.new
    Gamefic::Props::Output::WRITER_METHODS.each do |mthd|
      output.send(mthd, 'test value')
      expect(output.send(mthd.to_s[0..-2])).to eq('test value')
    end
  end

  it 'raises NoMethodError' do
    output = Gamefic::Props::Output.new
    expect { output.queue = 'my message' }.to raise_error(NoMethodError)
  end
end
