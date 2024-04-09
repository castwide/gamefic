# frozen_string_literal: true

describe Gamefic::Messenger do
  let(:messenger) { Gamefic::Messenger.new }

  it 'streams messages' do
    messenger.stream 'test'
    expect(messenger.messages).to eq('test')
  end

  it 'formats tells into paragraphs' do
    messenger.tell 'test'
    expect(messenger.messages).to eq('<p>test</p>')
  end

  it 'formats multiple paragraphs' do
    messenger.tell "paragraph 1\n\nparagraph 2"
    expect(messenger.messages).to eq('<p>paragraph 1</p><p>paragraph 2</p>')
  end

  it 'avoids redundant paragraphs' do
    messenger.tell '<p>paragraph</p>'
    expect(messenger.messages).to eq('<p>paragraph</p>')
  end

  it 'buffers messages' do
    buffered = messenger.buffer do
      messenger.stream 'buffered'
    end
    expect(buffered).to eq('buffered')
    expect(messenger.messages).to be_empty
  end
end
