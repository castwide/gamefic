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
    subplot.exeunt actor
    expect(actor.narratives.length).to eq(1)
    expect(actor.narratives).not_to include(subplot)
  end

  it 'adds entities to the host plot' do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    subplot.stage do
      plot.make Gamefic::Entity, name: 'thing'
    end
    expect(subplot.entities).to be_empty
    expect(plot.entities).to be_one
  end

  it 'runs ready blocks' do
    readied = false
    Gamefic::Subplot.script do
      on_ready do
        readied = true
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    subplot = Gamefic::Subplot.new(plot, introduce: actor)
    subplot.ready
    expect(readied).to be(true)
  end

  it 'runs update blocks' do
    updated = false
    Gamefic::Subplot.script do
      on_update do
        updated = true
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.introduce
    subplot = plot.branch(Gamefic::Subplot, introduce: actor)
    subplot.ready
    subplot.update
    expect(updated).to be(true)
  end

  it 'branches additional subplots' do
    plot = Gamefic::Plot.new
    subplot1 = plot.branch(Gamefic::Subplot)
    subplot2 = subplot1.branch(Gamefic::Subplot)
    expect(plot.subplots).to eq([subplot1, subplot2])
  end

  it 'warns of data changes during script setup' do
    # @todo Raise ScriptError from FrozenError
    Gamefic::Subplot.script do
      @wrong = 'wrong'
    end
    plot = Gamefic::Plot.new
    expect { plot.branch(Gamefic::Subplot) }.to raise_error(FrozenError)
  end

  it 'runs player conclude blocks' do
    Gamefic::Subplot.script do
      on_player_conclude do |player|
        player[:concluded] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    subplot = plot.branch Gamefic::Subplot, introduce: player
    subplot.conclude
    expect(player[:concluded]).to be(true)
  end
end
