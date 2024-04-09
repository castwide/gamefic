# frozen_string_literal: true

describe Gamefic::Active::Messaging do
  let(:object) { Object.new.extend Gamefic::Active::Messaging }

  it 'buffers messages' do
    buffered = object.buffer { object.stream 'hello' }
    expect(buffered).to eq('hello')
    expect(object.messages).to be_empty
  end
end
