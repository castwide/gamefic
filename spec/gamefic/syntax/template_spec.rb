# frozen_string_literal: true

describe Gamefic::Syntax::Template do
  describe '#to_template' do
    it 'returns self' do
      template = Gamefic::Syntax::Template.new('test')
      expect(template.to_template).to be(template)
    end
  end

  describe '#to_s' do
    it 'returns the text' do
      template = Gamefic::Syntax::Template.new('test')
      expect(template.to_s).to eq(template.text)
    end
  end

  describe '#compare' do
    it 'compares verbs when the lengths match' do
      tmp1 = Gamefic::Syntax::Template.new('verb1 noun1 noun2')
      tmp2 = Gamefic::Syntax::Template.new('verb2 noun3 noun4')
      expect(tmp1.compare(tmp2)).to eq(:verb2 <=> :verb1)
    end
  end
end
