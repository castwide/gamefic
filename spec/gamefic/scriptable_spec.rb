# frozen_string_literal: true

describe Gamefic::Scriptable do
  let(:scriptable) { Module.new.extend(Gamefic::Scriptable) }

  it 'includes blocks' do
    scriptable.instance_exec do
      pause :extended_pause
    end
    klass = Class.new(Gamefic::Narrative)
    klass.include scriptable
    narr = klass.new
    expect(narr.named_scenes).to include(:extended_pause)
  end

  it 'includes scriptable modules once' do
    # This test is necessary because Opal can duplicate included modules
    scriptable.instance_exec { @foo = Object.new }
    other = Module.new.extend(Gamefic::Scriptable)
    other.include scriptable
    klass = Class.new(Gamefic::Narrative)
    klass.include scriptable
    klass.include other
    expect(klass.included_scripts).to eq(klass.included_scripts.uniq)
  end

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
      attr_make :room, Gamefic::Entity,
                name: 'room'

      attr_make :item, Gamefic::Entity,
                name: 'item',
                parent: room

      introduction do |actor|
        actor.parent = room
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
      on_ready {}
    end

    plot = klass.new
    expect(plot.ready_blocks).to be_one
  end

  it 'scripts on_player_ready' do
    klass = Class.new(Gamefic::Plot) do
      on_player_ready {}
    end

    plot = klass.new
    expect(plot.ready_blocks).to be_one
  end

  it 'scripts on_update' do
    executed = false
    klass = Class.new(Gamefic::Plot) do
      on_update {}
    end

    plot = klass.new
    expect(plot.update_blocks).to be_one
  end

  it 'scripts on_player_update' do
    klass = Class.new(Gamefic::Plot) do
      on_player_update {}
    end

    plot = klass.new
    expect(plot.update_blocks).to be_one
  end

  it 'scripts before_command' do
    klass = Class.new(Gamefic::Plot) do
      respond(:foo) { |_| nil }
      before_command { |actor| actor[:executed] = true }
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'foo'
    expect(player[:executed]).to be(true)
  end

  it 'scripts after_command' do
    klass = Class.new(Gamefic::Plot) do
      attr_make :foo, Gamefic::Entity, name: 'foo'

      respond(:foo) { |_| nil }
      after_command { foo.name = 'bar' }
    end

    plot = klass.new
    player = plot.introduce
    player.perform 'foo'
    expect(plot.foo.name).to eq('bar')
  end

  it 'scripts conclusion' do
    klass = Class.new(Gamefic::Plot) do
      conclusion(:ending) {}
    end

    plot = klass.new
    # Three scenes including default_scene and default_conclusion
    expect(plot.scenes.length).to eq(3)
  end

  it 'scripts attribute seeds' do
    klass = Class.new(Gamefic::Plot) do
      construct :foo, Gamefic::Entity, name: 'foo'
    end

    plot = klass.new
    expect(plot.foo.name).to eq('foo')
  end
end
