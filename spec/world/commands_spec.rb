describe Gamefic::World::Commands do
  let(:object) {
    object = Object.new
    object.extend Gamefic::World::Commands
    object
  }

  it "creates an action" do
    object.respond :command do |actor|
      puts 'command'
    end
    expect(object.playbook.actions.length).to eq(1)
    expect(object.playbook.actions.first.verb).to eq(:command)
  end

  it "creates a meta action" do
    object.meta :command do |actor|
      puts 'command'
    end
    expect(object.playbook.actions.length).to eq(1)
    expect(object.playbook.actions.first.verb).to eq(:command)
    expect(object.playbook.actions.first).to be_meta
  end

  it 'parses an action' do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity, name: 'a thing'
    action = plot.parse(:touch, 'thing')
    expect(action.verb).to eq(:touch)
  end

  it 'raises errors on parses with bad tokens' do
    plot = Gamefic::Plot.new
    expect {
      plot.parse(:touch, 'a nonexistent thing')
    }.to raise_error(ArgumentError)
  end

  it 'overrides commands' do
    plot = Gamefic::Plot.new
    actor = Gamefic::Actor.new
    thing = plot.make Gamefic::Entity, name: 'a thing'
    base = plot.respond :handle, Gamefic::Query::Family.new(Gamefic::Entity) do |actor, thing|
      actor.tell "Version 1"
    end
    act1 = base.new(actor, [thing])
    act1.execute
    expect(actor.messages).to include('Version 1')
    over = plot.override 'handle a thing' do |actor, thing|
      actor.tell "Version 2"
    end
    expect(over.superclass).to be(Gamefic::Action)
    act2 = over.new(actor, [thing])
    act2.execute
    expect(actor.messages).to include('Version 2')
  end

  it 'maps entity arguments to default queries' do
    plot = Gamefic::Plot.new
    entity = plot.make Gamefic::Entity, name: 'an entity'
    action = plot.respond(:handle, entity) { |actor, entity| }
    expect(action.queries.length).to eq(1)
    expect(action.queries.first).to be_a(plot.get_default_query)
  end

  it 'maps regular expressions to text queries' do
    plot = Gamefic::Plot.new
    action = plot.respond(:handle, /text/) { |actor, text| }
    expect(action.queries.length).to eq(1)
    expect(action.queries.first).to be_a(Gamefic::Query::Text)
  end

  it 'raises ArgumentError for invalid parameters' do
    plot = Gamefic::Plot.new
    expect {
      plot.respond(:handle, Object.new)
    }.to raise_error(ArgumentError)
  end

  it 'maps entity classes to default queries' do
    plot = Gamefic::Plot.new
    action = plot.respond(:handle, Gamefic::Entity) { |actor, entity| }
    expect(action.queries.first.arguments.first).to be(Gamefic::Entity)
  end

  it 'sets a default query' do
    object.set_default_query Gamefic::Query::Tree
    thing = Gamefic::Entity.new
    # @type [Class<Gamefic::Action>]
    action = object.respond(:command, thing)
    expect(action.queries.map(&:class)).to eq([Gamefic::Query::Tree])
  end
end
