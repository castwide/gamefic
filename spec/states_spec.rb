require "gamefic"
include Gamefic

describe CharacterState::Prompted do
  it "executes a proc" do
    num = 0
    p = CharacterState::Prompted.new "Wait for it..." do |character, line|
      num = 1
    end
    p.accept nil, nil
    expect(num).to eq(1)
  end
end
