describe Gamefic::Messaging do
  let(:object) {
    object = Object.new
    object.extend Gamefic::Messaging
    object
  }

  it 'streams messages' do
    object.stream 'test'
    expect(object.messages).to eq('test')
  end

  it 'formats tells into paragraphs' do
    object.tell 'test'
    expect(object.messages).to eq('<p>test</p>')
  end

  it 'formats multiple paragraphs' do
    object.tell "paragraph 1\n\nparagraph 2"
    expect(object.messages).to eq('<p>paragraph 1</p><p>paragraph 2</p>')
  end

  it 'avoids redundant paragraphs' do
    object.tell '<p>paragraph</p>'
    expect(object.messages).to eq('<p>paragraph</p>')
  end
end
