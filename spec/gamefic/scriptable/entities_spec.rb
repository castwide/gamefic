# frozen_string_literal: true

describe Gamefic::Scriptable::Entities do
  let(:object) {
    Object.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Entities
    end
  }

  describe '#pick!' do
    it 'finds a match' do
      exist = object.make Gamefic::Entity, name: 'red dog'
      match = object.pick! 'red'
      expect(exist).to be(match)
    end

    it 'raises when there is no match' do
      expect {
        object.pick! 'something that does not exist'
      }.to raise_error(RuntimeError)
    end

    it 'raises when there is are multiple matches' do
      object.make Gamefic::Entity, name: 'red dog'
      object.make Gamefic::Entity, name: 'red house'
      expect {
        object.pick! 'red'
      }.to raise_error(RuntimeError)
    end
  end
end
