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

  it "adds its playbook to casted characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = subplot.cast Gamefic::Actor.new
    expect(actor.playbooks).to include(subplot.playbook)
  end

  it "adds its playbook to introduced characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.make_player_character
    plot.introduce actor
    subplot.introduce actor
    expect(actor.playbooks.length).to eq(2)
    expect(actor.playbooks).to include(subplot.playbook)
  end

  it "removes its playbook from exited characters" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    actor = plot.cast Gamefic::Actor.new
    subplot.introduce actor
    subplot.exeunt actor
    expect(actor.playbooks.length).to eq(1)
    expect(actor.playbooks).not_to include(subplot.playbook)
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
end
