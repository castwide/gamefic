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
    expect(actor.rulebooks).to include(subplot.rulebook)
  end

  it "adds its rulebook to introduced characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.make_player_character
    plot.introduce actor
    subplot.introduce actor
    expect(actor.rulebooks.length).to eq(2)
    expect(actor.rulebooks).to include(subplot.rulebook)
  end

  it "removes its rulebook from exited characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.cast Gamefic::Actor.new
    subplot.introduce actor
    subplot.exeunt actor
    expect(actor.rulebooks.length).to eq(1)
    expect(actor.rulebooks).not_to include(subplot.rulebook)
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
    klass = Class.new(Gamefic::Subplot)
    klass.script do
      on_ready do
        readied = true
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.make_player_character
    subplot = klass.new(plot, introduce: actor)
    subplot.ready
    expect(readied).to be(true)
  end

  it 'runs update blocks' do
    updated = false
    klass = Class.new(Gamefic::Subplot)
    klass.script do
      on_update do
        updated = true
      end
    end
    plot = Gamefic::Plot.new
    actor = plot.make_player_character
    subplot = klass.new(plot, introduce: actor)
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
    expect(Gamefic::Logging.logger).to receive(:warn).with(/data changed during script setup/)
    Gamefic::Subplot.script do
      session[:test] = 'bad practice'
    end
    plot = Gamefic::Plot.new
    subplot = plot.branch(Gamefic::Subplot)
  end

  it 'delegates attributes to plots' do
    Gamefic.seed { @foo = 'foo' }
    Gamefic::Plot.attr_delegate :foo
    Gamefic::Subplot.attr_host :foo
    plot = Gamefic::Plot.new
    subplot = plot.branch(Gamefic::Subplot)
    expect(subplot.foo).to eq('foo')
  end
end
