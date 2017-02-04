# TODO: Assertions are temporarily disabled

%(
describe "Assertion" do
  before :each do
    @plot = Plot.new
    @character= @plot.make Character, :name => "player"
    @number = 0
    @plot.respond :increment do |actor|
      @number += 1
    end
  end
  it "gets executed by an action" do
    @plot.assert_action :increment_number do |actor, verb, arguments|
      @number += 1
    end
    @character.perform "increment"
    expect(@number).to eq(2)
  end
  it "validates a user action by returning true" do
    @plot.assert_action :return_true do |actor, verb, arguments|
      true
    end
    @character.perform "increment"
    expect(@number).to eq(1)
  end
  it "invalidates a user action by returning false" do
    @plot.assert_action :return_false do |actor, verb, arguments|
      false
    end
    @character.perform "increment"
    expect(@number).to eq(0)
  end
  it "skips assertion rules if the first action is Meta" do
    @plot.assert_action :return_false do |actor, verb, arguments|
      false
    end
    @plot.meta :meta do |actor|
      @number += 1
    end
    @character.perform "meta"
    expect(@number).to eq(1)
  end
end
)
