require "gamefic"
include Gamefic

describe Character do
  it "performs an action" do
    plot = Plot.new
    character = plot.make Character
    x = 0
    plot.respond :increment_number do |actor|
      x += 1
    end
    character.perform "increment number"
    expect(x).to eq(1)
  end
  it "formats #tell messages into HTML paragraphs" do
    plot = Plot.new
    user = User::Base.new
    character = plot.make Character
    character.connect user
    character.tell "This is one paragraph."
    expect(user.flush).to eq("<p>This is one paragraph.</p>")
  end
  it "splits #tell messages into multiple paragraphs" do
    plot = Plot.new
    user = User::Base.new
    character = plot.make Character
    character.connect user
    character.tell "This is paragraph 1.\n\nThis is paragraph 2.\r\n\r\nThis is paragraph 3."
    expect(user.flush).to eq("<p>This is paragraph 1.</p><p>This is paragraph 2.</p><p>This is paragraph 3.</p>")
  end
end
