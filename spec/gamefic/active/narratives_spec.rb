# frozen_string_literal: true

describe Gamefic::Active::Narratives do
  describe '#understand?' do
    let(:klass) do
      Class.new(Gamefic::Plot) do
        respond(:foo) {}

        respond(nil, plaintext) {}

        interpret 'bar', 'foo'
      end
    end

    let(:narratives) { Gamefic::Active::Narratives.new.add(klass.new) }

    it 'returns true for known verbs' do
      expect(narratives.understand?('foo')).to be(true)
    end

    it 'returns true for known syntax synonyms' do
      expect(narratives.understand?('bar')).to be(true)
    end

    it 'returns false for unknown verbs' do
      expect(narratives.understand?('baz')).to be(false)
    end

    it 'returns false for nil' do
      expect(narratives.understand?(nil)).to be(false)
    end
  end
end
