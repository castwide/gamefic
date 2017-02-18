describe Subplot do
  it "destroys its elements upon conclusion" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    subplot.conclude
    expect(plot.entities.include? entity).to be(false)
  end
end
