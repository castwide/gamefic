# frozen_string_literal: true

describe Gamefic::Chapter do
  it 'does not duplicate ready blocks' do
    scriptable = Module.new do
      extend Gamefic::Scriptable

      on_player_ready {}
    end

    chapter_klass = Class.new(Gamefic::Chapter) do
      include scriptable
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
      append chapter_klass
    end

    plot = plot_klass.new
    expect(plot.ready_blocks).to be_one
  end

  it 'does not duplicate introductions' do
    scriptable = Module.new do
      extend Gamefic::Scriptable

      introduction {}
    end

    chapter_klass = Class.new(Gamefic::Chapter) do
      include scriptable
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
      append chapter_klass
    end

    plot = plot_klass.new
    expect(plot.introductions).to be_one
  end

  it 'does not duplicate seeds' do
    scriptable = Module.new do
      extend Gamefic::Scriptable

      make Gamefic::Entity, name: 'thing'
    end

    chapter_klass = Class.new(Gamefic::Chapter) do
      include scriptable
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
      append chapter_klass
    end

    plot = plot_klass.new
    expect(plot.entities).to be_one
    expect(plot.chapters.first.entities).to be_empty
  end

  it 'binds methods from plots' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      bind_from_plot :thing
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass

      construct :thing, Gamefic::Entity, name: 'thing'
    end

    plot = plot_klass.new
    expect(plot.chapters.first.thing).to be(plot.thing)
  end

  it 'executes responses' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      bind_from_plot :thing

      respond :take, thing do |actor|
        thing.parent = actor
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass

      construct :room, Gamefic::Entity, name: 'room'
      construct :thing, Gamefic::Entity, name: 'thing', parent: room

      introduction do |actor|
        actor.parent = room
      end
    end

    plot = plot_klass.new
    player = plot.introduce
    player.perform 'take thing'
    expect(plot.thing.parent).to be(player)
  end
end
