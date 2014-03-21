require "gamefic"
include Gamefic

describe Keywords do
	it "filters articles" do
		Keywords.new("a word").length.should eq(1)
		Keywords.new("an word").length.should eq(1)
		Keywords.new("the word").length.should eq(1)
	end
	it "filters single characters" do
		Keywords.new("a b see").join.should eq("see")
	end
	it "reduces words to alphanumeric characters" do
		Keywords.new("it's").join.should eq("it")
	end
	it "finds matches" do
		k1 = Keywords.new("one two three")
		k2 = Keywords.new("three four five")
		k1.found_in(k2).should eq(1)
	end
	it "finds partial matches" do
		k1 = Keywords.new("half")
		k2 = Keywords.new("halffull")
		k1.found_in(k2).should eq(0.5)
	end
	it "scores zero for keywords without matches" do
		k1 = Keywords.new("this")
		k2 = Keywords.new("that")
		k1.found_in(k2).should eq(0)
	end
end
