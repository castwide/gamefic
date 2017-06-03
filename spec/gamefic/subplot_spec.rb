describe Subplot do
  it "destroys its elements upon conclusion" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    expect(subplot.entities.include? entity).to be(true)
    subplot.conclude
    expect(subplot.entities.include? entity).to be(false)
  end

  it "adds its host's playbook to casted characters" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    actor = subplot.cast Actor
    expect(actor.playbooks).to include(plot.playbook)
  end

  it "adds its playbook to casted characters" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    actor = subplot.cast Actor
    expect(actor.playbooks.length).to eq(2)
    expect(actor.playbooks).to include(subplot.playbook)
  end

  it "adds its playbook to introduced characters" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    actor = plot.cast Actor
    subplot.introduce actor
    expect(actor.playbooks.length).to eq(2)
    expect(actor.playbooks).to include(subplot.playbook)
  end

  it "removes its playbook from exited characters" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    actor = plot.cast Actor
    subplot.introduce actor
    subplot.exeunt actor
    expect(actor.playbooks.length).to eq(1)
    expect(actor.playbooks).to_not include(subplot.playbook)
  end
end
