describe Gamefic::Entity do
  describe '#parent=' do
    it 'raises if parent is not an entity' do
      entity = Gamefic::Entity.new
      expect { entity.parent = 0 }.to raise_error(ArgumentError)
    end
  end
end
