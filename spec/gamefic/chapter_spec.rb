# frozen_string_literal: true

describe Gamefic::Chapter do
  it 'seeds entities on its narrative' do
    chap_klass = Class.new(Gamefic::Chapter) do
      seed do
        @thing = make Gamefic::Entity, name: 'thing'
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.entities.map(&:name)).to eq(['thing'])
    expect(plot.chapters.first.instance_eval { @thing }).to be(plot.entities.first)
  end

  it 'creates responses in the narrative rulebook' do
    chap_klass = Class.new(Gamefic::Chapter) do
      script do
        respond(:chapter) {}
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.rulebook.verbs).to eq([:chapter])
  end

  it 'uses its own variable space' do
    target = nil

    chap_klass = Class.new(Gamefic::Chapter) do
      seed do
        @this_one = 'chap_klass'
      end

      script do
        respond(:target) { target = @this_one }
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass

      seed do
        @this_one = 'plot_klass'
      end
    end

    plot = plot_klass.new
    player = plot.introduce
    player.perform 'target'
    expect(target).to eq('chap_klass')
  end

  it 'makes entities in the plot' do
    chap_klass = Class.new(Gamefic::Chapter) do
      seed do
        make Gamefic::Entity, name: 'second'
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass

      seed do
        make Gamefic::Entity, name: 'first'
      end
    end

    plot = plot_klass.new
    expect(plot.entities).to be(plot.chapters.first.entities)
    expect(plot.entities.map(&:name)).to eq(['first', 'second'])
    expect(plot.pick('second')).to be
    expect(plot.chapters.first.pick('first')).to be
  end

  it 'adds event callbacks to plots' do
    chap_klass = Class.new(Gamefic::Chapter) do
      on_player_ready do |actor|
        actor[:ready] = true
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass
    end

    plot = plot_klass.new
    player = plot.introduce
    plot.ready
    expect(player[:ready]).to be(true)
  end

  it 'does not repeat scripts included in the plot' do
    scriptable = Module.new do
      extend Gamefic::Scriptable
      make_seed Gamefic::Entity, name: 'thing'
      respond(:foo) {}
    end

    chap_klass = Class.new(Gamefic::Chapter) do
      include scriptable
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.rulebook.responses).to be_one
    expect(plot.rulebook.verbs).to eq([:foo])
    expect(plot.entities).to be_one
  end

  it 'accesses plot proxies' do
    chap_klass = Class.new(Gamefic::Chapter) do
      attr_seed :thing, Gamefic::Entity, name: 'thing', parent: plot_attr(:room)
    end

    plot_klass = Class.new(Gamefic::Plot) do
      attr_seed :room, Gamefic::Entity, name: 'room'

      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.chapters.first.thing.parent).to be(plot.room)
  end
end
