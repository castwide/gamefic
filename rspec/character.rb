require_relative "../lib/gamefic"
include Gamefic

describe Character do
	it "performs an action" do
		plot = Plot.new
		character = plot.make Character
		x = 0
		plot.respond :increment_number do |actor|
			x = x + 1
		end
		character.perform "increment number"
		x.should eq(1)
	end
end
