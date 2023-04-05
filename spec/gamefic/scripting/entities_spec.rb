# frozen_string_literal: true

describe Gamefic::Scripting::Entities do
  let(:object) { Object.new.tap { |obj| obj.extend Gamefic::Scripting::Entities } }

  describe '#make' do
    it 'allocates an entity' do
      entity = object.make Gamefic::Entity, name: 'thing'
      expect(entity).to be_a(Gamefic::Entity)
    end
  end
end
