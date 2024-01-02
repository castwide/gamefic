describe Gamefic::Scripting do
  it 'scripts introductions' do
    klass = Class.new(Gamefic::Plot) do
      introduction do |actor|
        actor[:introduced] = true
      end
    end

    plot = klass.new
    player = plot.introduce
    expect(player[:introduced]).to be(true)
  end

  it 'scripts responses' do
    klass = Class.new(Gamefic::Plot) do
      seed do
        @room = make Gamefic::Entity, name: 'room'
        @item = make Gamefic::Entity, name: 'item', parent: @room
      end

      attr_reader :item

      introduction do |actor|
        actor.parent = @room
      end

      respond(:take, Gamefic::Entity) do |actor, entity|
        entity.parent = actor
      end
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'take item'
    expect(player.children).to include(plot.item)
  end

  it 'scripts responses with arguments' do
  end

  it 'scripts meta responses' do
    klass = Class.new(Gamefic::Plot) do
      meta(:execute) { |actor| actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'execute'
    expect(player[:executed]).to be(true)
  end

  it 'scripts on_ready' do
    executed = false
    klass = Class.new(Gamefic::Plot) do
      on_ready { executed = true }
    end

    plot = klass.new
    player = plot.introduce
    plot.ready
    expect(executed).to be(true)
  end

  it 'scripts on_player_ready' do
    klass = Class.new(Gamefic::Plot) do
      on_player_ready { |actor| actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    plot.ready
    expect(player[:executed]).to be(true)
  end

  it 'scripts on_update' do
    executed = false
    klass = Class.new(Gamefic::Plot) do
      on_update { executed = true }
    end

    plot = klass.new
    player = plot.introduce
    plot.update
    expect(executed).to be(true)
  end

  it 'scripts on_player_update' do
    klass = Class.new(Gamefic::Plot) do
      on_player_update { |actor| actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    plot.update
    expect(player[:executed]).to be(true)
  end

  it 'scripts before_action' do
    klass = Class.new(Gamefic::Plot) do
      respond(:foo) { |_| nil }
      before_action { |action| action.actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'foo'
    expect(player[:executed]).to be(true)
  end

  it 'scripts after_action' do
    klass = Class.new(Gamefic::Plot) do
      attr_reader :foo

      seed { @foo = make Gamefic::Entity, name: 'foo' }
      respond(:foo) { |_| nil }
      after_action { |_action| @foo.name = 'bar' }
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'foo'
    expect(plot.foo.name).to eq('bar')
  end

  it 'scripts conclusion' do
    klass = Class.new(Gamefic::Plot) do
      conclusion(:ending) { |actor| actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    player.cue :ending
    plot.ready
    expect(player[:executed]).to be(true)
  end

  it 'seeds entity attributes with proxies' do
    klass = Class.new(Gamefic::Plot) do
      attr_seed :room, Gamefic::Entity, name: 'room'
      attr_seed :thing, Gamefic::Entity, name: 'thing', parent: proxy(:room)
    end

    plot = klass.new
    expect(plot.thing.name).to eq('thing')
    expect(plot.thing.parent).to be(plot.room)
  end
end
