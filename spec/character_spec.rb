require "gamefic"
include Gamefic

describe Character do
	it "performs an action" do
		plot = Plot.new
		character = plot.make Character
		x = 0
		plot.respond :increment_number do |actor|
			x = x + 1
		end
		character.perform "increment_number"
		expect(x).to eq(1)
	end
  it "formats #tell messages into HTML paragraphs" do
    plot = Plot.new
    user = User.new plot
    user.character.tell "This is one paragraph."
    expect(user.stream.flush).to eq("<p>This is one paragraph.</p>")
  end
  it "formats newlines in #tell messages into HTML line breaks and paragraphs" do
    plot = Plot.new
    user = User.new plot
    user.character.tell "This is a paragraph with a \nline break.\n\nThis is a second paragraph."
    expect(user.stream.flush).to eq("<p>This is a paragraph with a <br/>line break.</p><p>This is a second paragraph.</p>")
  end
end
