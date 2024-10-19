# frozen_string_literal: true

describe Gamefic::Subplot do
  it "destroys its elements upon conclusion" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    entity = subplot.make(Gamefic::Entity, name: 'entity')
    expect(subplot.entities.include? entity).to be(true)
    subplot.conclude
    expect(subplot.entities.include? entity).to be(false)
  end

  it "adds its rulebook to casted characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = subplot.cast Gamefic::Actor.new
    expect(actor.narratives).to include(subplot)
  end

  it "adds its rulebook to introduced characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.introduce
    subplot.introduce actor
    expect(actor.narratives.length).to eq(2)
    expect(actor.narratives).to include(subplot)
  end

  it "removes its rulebook from exited characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.cast Gamefic::Actor.new
    subplot.introduce actor
    subplot.uncast actor
    expect(actor.narratives.length).to eq(1)
    expect(actor.narratives).not_to include(subplot)
  end

  it 'adds entities to the host plot' do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    subplot.instance_exec do
      plot.make Gamefic::Entity, name: 'thing'
    end
    expect(subplot.entities).to be_empty
    expect(plot.entities).to be_one
  end

  it 'branches additional subplots' do
    plot = Gamefic::Plot.new
    subplot1 = plot.branch(Gamefic::Subplot)
    subplot2 = subplot1.branch(Gamefic::Subplot)
    expect(plot.subplots).to eq([subplot1, subplot2])
  end

  it 'runs player conclude blocks' do
    klass = Class.new(Gamefic::Subplot) do
      on_player_conclude do |player|
        player[:concluded] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    subplot = plot.branch klass, introduce: player
    subplot.conclude
    expect(player[:concluded]).to be(true)
  end

  # @todo This test might not be necessary anymore. Repeating scripts will be
  #   less of a concern going forward, especially since seeds no longer exist
  #   in scriptable modules.
  it 'does not repeat scripts included in the plot' do
    scriptable = Module.new do
      extend Gamefic::Scriptable
      respond(:foo) {}
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
    end

    subplot_klass = Class.new(Gamefic::Subplot) do
      include scriptable
    end

    plot = plot_klass.new
    subplot = plot.branch(subplot_klass)
    expect(subplot.class.responses).to be_empty
  end

  it 'is not usually persistent' do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    expect(subplot).not_to be_persistent
    expect(subplot).to be_concluding
  end

  it 'can be persistent' do
    klass = Class.new(Gamefic::Subplot) do
      persist!
    end

    plot = Gamefic::Plot.new
    subplot = plot.branch klass
    expect(subplot).to be_persistent
    expect(subplot).not_to be_concluding
    subplot.conclude
    expect(subplot).to be_concluding
  end

  it 'proxies config' do
    executed = false

    klass = Class.new(Gamefic::Subplot) do
      def configure
        config[:thing] = make Gamefic::Entity, name: 'thing'
      end

      respond(:execute, anywhere(config[:thing])) { executed = true }
    end

    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.branch klass, introduce: player
    player.perform 'execute thing'
    expect(executed).to be(true)
  end
end
