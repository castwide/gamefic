# frozen_string_literal: true

describe Gamefic::Subplot do
  it "destroys its elements upon conclusion" do
    plot = Gamefic::Plot.new
    subplot = Gamefic::Subplot.new(plot)
    proxy = subplot.make(Gamefic::Entity, name: 'entity')
    expect(subplot.entities.include? proxy.entity).to be(true)
    subplot.conclude
    expect(subplot.entities.include? proxy.entity).to be(false)
  end

  # @todo This might not be necessary, but if we do it, the player's playbook
  #   should be a Set.
  # it "adds its host's playbook to casted characters" do
  #   plot = Gamefic::Plot.new
  #   subplot = Gamefic::Subplot.new(plot)
  #   actor = subplot.cast Gamefic::Actor
  #   expect(actor.playbooks).to include(plot.playbook)
  # end

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

  it 'proceeds in tandem with plots' do
    readied = false
    updated = false
    klass = Class.new(Gamefic::Subplot)
    klass.script do
      on_ready do
        readied = true
      end
      on_update do
        updated = true
      end
    end
    plot = Gamefic::Plot.new
    subplot = klass.new(plot)
    # @todo Subplot#plot should probably be responsible for this.
    plot.subplots.push subplot
    # @todo The subplot needs at least one player to avoid being concluded.
    #   See Subplot#ready
    # actor = plot.cast Gamefic::Actor
    # subplot.introduce actor
    plot.ready
    expect(readied).to be(true)
    plot.update
    expect(updated).to be(true)
  end
end
