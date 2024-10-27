# frozen_string_literal: true

describe Gamefic::Entity do
  it 'inspects the name' do
    entity = Gamefic::Entity.new(name: 'thing')
    expect(entity.inspect).to eq('#<Gamefic::Entity \'thing\'>')
  end

  it 'inherits default attributes' do
    klass1 = Class.new(Gamefic::Entity) do
      attr_accessor :attribute
    end
    klass1.set_default(attribute: 'one')

    klass2 = Class.new(klass1)
    klass2.set_default(attribute: 'two')

    klass3 = Class.new(klass1)

    entity1 = klass1.new
    expect(entity1.attribute).to eq('one')

    entity2 = klass2.new
    expect(entity2.attribute).to eq('two')

    entity3 = klass3.new
    expect(entity3.attribute).to eq('one')
  end

  it 'leaves parents' do
    room = Gamefic::Entity.new(name: 'room')
    person = Gamefic::Actor.new(name: 'person', parent: room)
    thing = Gamefic::Entity.new(name: 'thing', parent: person)

    expect(thing.parent).to be(person)
    thing.leave
    expect(thing.parent).to be(room)
  end

  it 'broadcasts to participating actors' do
    plot = Gamefic::Plot.new
    room = plot.make(Gamefic::Entity, name: 'room')
    container = plot.make(Gamefic::Entity, name: 'thing', parent: room)
    person = plot.introduce
    person.parent = container

    room.broadcast 'Hello, world!'
    expect(person.messages).to include('Hello, world!')
  end

  it 'does not broadcast to non-participants' do
    plot = Gamefic::Plot.new
    room = plot.make(Gamefic::Entity, name: 'room')
    container = plot.make(Gamefic::Entity, name: 'thing', parent: room)
    person = plot.make(Gamefic::Actor, name: 'person', parent: container)

    room.broadcast 'Hello, world!'
    expect(person.messages).to be_empty
  end
end
