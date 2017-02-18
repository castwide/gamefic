describe Subplot do
  it "destroys its elements upon conclusion" do
    plot = Plot.new
    subplot = Subplot.new(plot)
    entity = subplot.make(Entity, name: 'entity')
    expect(subplot.entities.include? entity).to be(true)
    subplot.conclude
    expect(subplot.entities.include? entity).to be(false)
  end
end
