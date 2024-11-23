# frozen_string_literal: true

describe Gamefic::Syntax::Template do
  describe '#to_s' do
    it 'returns the text' do
      template = Gamefic::Syntax::Template.new('test')
      expect(template.to_s).to eq(template.text)
    end
  end
end
