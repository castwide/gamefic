# frozen_string_literal: true

describe Gamefic::Delegatable::Entities do
  let(:object) {
    Class.new do
      include Gamefic::Delegatable::Entities

      def entity_vault
        @entity_vault ||= Gamefic::Vault.new
      end
    end
    .new
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
