require_relative "./../lib/gamefic"
include Gamefic

describe Array do
	it "filters by class" do
		array = [0, 1, "two", 3]
		filtered = array.that_are(String)
		filtered.length.should eq(1)
		filtered = array.that_are_not(String)
		filtered.length.should eq(3)
	end
	it "joins with a conjunction" do
		array = ["one", "two", "three"]
		array.join_and.should eq("one, two, and three")
		array.join_and(', ', ' or ').should eq("one, two, or three")
	end
end
