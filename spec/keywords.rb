require "gamefic"
include Gamefic

describe Keywords do
	it "filters articles" do
		expect(Keywords.new("a word").length).to eq(1)
		expect(Keywords.new("an word").length).to eq(1)
		expect(Keywords.new("the word").length).to eq(1)
	end
	it "filters single characters" do
		expect(Keywords.new("a b see").join).to eq("see")
	end
	it "reduces words to alphanumeric characters" do
		expect(Keywords.new("it's").join).to eq("it")
	end
	it "finds matches" do
		k1 = Keywords.new("one two three")
		k2 = Keywords.new("three four five")
		expect(k1.found_in(k2)).to eq(1)
	end
	it "finds partial matches" do
		k1 = Keywords.new("half")
		k2 = Keywords.new("halffull")
		expect(k1.found_in(k2)).to eq(0.5)
	end
	it "scores zero for keywords without matches" do
		k1 = Keywords.new("this")
		k2 = Keywords.new("that")
		expect(k1.found_in(k2)).to eq(0)
	end
end
