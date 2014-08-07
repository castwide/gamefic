require "gamefic"
include Gamefic

describe Array do
	it "filters by class" do
		array = [0, 1, "two", 3]
		filtered = array.that_are(String)
		filtered.length.should eq(1)
    filtered[0].should eq("two")
	end
  it "excludes by class" do
		array = [0, 1, "two", 3]
		filtered = array.that_are_not(String)
		filtered.length.should eq(3)
    filtered.include?("two").should eq(false)  
  end
	it "joins with a conjunction" do
		array = ["one", "two", "three"]
		array.join_and.should eq("one, two, and three")
		array.join_and(', ', ' or ').should eq("one, two, or three")
	end
  it "joins two elements with the \"and\" separator" do
    array = ["one", "two"]
    array.join_and.should eq("one and two")
  end
end
