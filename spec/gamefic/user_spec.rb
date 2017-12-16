describe Gamefic::User::Base do
=begin
  it "accepts an Actor connection" do
    user = Gamefic::User::Base.new nil
    character = Gamefic::Actor.new
    user.connect character
    expect(user.character).to be(character)
  end

  it "accepts an Active connection" do
    user = Gamefic::User::Base.new nil
    entity = Gamefic::Entity.new
    entity.extend Gamefic::Active
    user.connect entity
    expect(user.character).to be(entity)
  end

  it "does not accept a connection to an object that is not Active" do
    user = Gamefic::User::Base.new nil
    object = Object.new
    expect {
      user.connect object
    }.to raise_error TypeError
  end
=end
end
