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
    expect(object.playbook.responses.length).to eq(1)
    expect(object.playbook.responses.first.verb).to eq(:command)
  end

  it "creates a meta action" do
    object.meta :command do |actor|
      puts 'command'
    end
    expect(object.playbook.responses.length).to eq(1)
    expect(object.playbook.responses.first.verb).to eq(:command)
    expect(object.playbook.responses.first).to be_meta
  end

  it 'parses an action' do
    object.make Gamefic::Entity, name: 'a thing'
    action = object.parse(:touch, 'thing')
    expect(action.verb).to eq(:touch)
  end

  it 'raises errors on parses with bad tokens' do
    expect {
      object.parse(:touch, 'a nonexistent thing')
    }.to raise_error(ArgumentError)
  end

  it 'overrides commands' do
    actor = Gamefic::Actor.new
    thing = object.make Gamefic::Entity, name: 'a thing'
    base = object.respond :handle, Gamefic::Query::Family.new(Gamefic::Entity) do |actor, _thing|
      actor.tell "Version 1"
    end
    act1 = Gamefic::Action.new(actor, [thing], base)
    act1.execute
    expect(actor.messages).to include('Version 1')
    over = object.override 'handle a thing' do |actor, _thing|
      actor.tell "Version 2"
    end
    act2 = Gamefic::Action.new(actor, [thing], over)
    act2.execute
    expect(actor.messages).to include('Version 2')
  end

  it 'maps entity arguments to default queries' do
    entity = object.make Gamefic::Entity, name: 'an entity'
    action = object.respond(:handle, entity) { |_actor, _entity| }
    expect(action.queries.length).to eq(1)
    expect(action.queries.first).to be_a(object.get_default_query)
  end

  it 'maps regular expressions to text queries' do
    action = object.respond(:handle, /text/) { |actor, text| }
    expect(action.queries.length).to eq(1)
    expect(action.queries.first).to be_a(Gamefic::Query::Text)
  end

  it 'raises ArgumentError for invalid parameters' do
    expect {
      object.respond(:handle, Object.new)
    }.to raise_error(ArgumentError)
  end

  it 'maps entity classes to default queries' do
    action = object.respond(:handle, Gamefic::Entity) { |actor, entity| }
    expect(action.queries.first.arguments.first).to be(Gamefic::Entity)
  end

  it 'sets a default query' do
    object.set_default_query Gamefic::Query::Tree
    thing = Gamefic::Entity.new
    # @type [Class<Gamefic::Action>]
    action = object.respond(:command, thing)
    expect(action.queries.map(&:class)).to eq([Gamefic::Query::Tree])
  end

  it 'creates an after action' do
    object.after_action do |action|
      action.actor.tell "Command executed: #{action.verb}"
    end
    expect(object.playbook.after_actions).to be_one
  end
end
