describe Gamefic::Entity do
  it 'inspects the name' do
    entity = Gamefic::Entity.new(name: 'thing')
    expect(entity.inspect).to eq('#<Gamefic::Entity thing>')
  end

  it 'inherits default attributes' do
    klass1 = Class.new(Gamefic::Entity) do
      attr_accessor :attribute
    end
    klass1.set_default(attribute: 'one')

    klass2 = Class.new(klass1)
    klass2.set_default(attribute: 'two')

    entity1 = klass1.new
    expect(entity1.attribute).to eq('one')

    entity2 = klass2.new
    expect(entity2.attribute).to eq('two')
  end
end
