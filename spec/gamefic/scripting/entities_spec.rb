# frozen_string_literal: true

describe Gamefic::Scripting::Entities do
  let(:object) { Object.new.tap { |obj| obj.extend Gamefic::Scripting::Entities } }

  describe '#make' do
    it 'makes an entity' do
      entity = object.make Gamefic::Entity, name: 'thing'
      expect(entity.name).to eq('thing')
    end
  end

  describe '#eid' do
    it 'returns an entity' do
      entity = object.make Gamefic::Entity, eid: :thing
      expect(object.eid(:thing)).to be(entity)
    end

    it 'raises an error' do
      expect { object.eid(:not_made) }.to raise_error(NameError)
    end
  end
end
