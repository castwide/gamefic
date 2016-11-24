describe Subplot do
  it "extends dynamic entities with Subplot::Element" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    expect(entity.kind_of? Subplot::Element).to be(true)
  end
  it "adds dynamic entities to the host" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    expect(plot.entities.include? entity).to be(true)
  end
  it "destroys its elements upon conclusion" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    subplot.conclude
    expect(plot.entities.include? entity).to be(false)
  end
end
