describe Director::Delegate do
  it "can proceed to the next action in the stack" do
    plot = Plot.new
    character = plot.make Character
    number = 0
    plot.respond :increment do |actor|
      number += 1
    end
    plot.respond :increment do |actor|
      number += 2
      actor.proceed
    end
    plot.perform character, "increment"
    expect(number).to eq(3)
  end
end
