require "gamefic"
# include Gamefic

describe Array do
  it "filters by class" do
    array = [0, 1, "two", 3]
    filtered = array.that_are(String)
    expect(filtered.length).to eq(1)
    expect(filtered[0]).to eq("two")
  end

  it "excludes by class" do
    array = [0, 1, "two", 3]
    filtered = array.that_are_not(String)
    expect(filtered.length).to eq(3)
    expect(filtered.include?("two")).to eq(false)  
  end

  it "joins with a conjunction" do
    array = ["one", "two", "three"]
    expect(array.join_and).to eq("one, two, and three")
    expect(array.join_and(', ', ' or ')).to eq("one, two, or three")
  end

  it "joins two elements with the \"and\" separator" do
    array = ["one", "two"]
    expect(array.join_and).to eq("one and two")
  end

  it "joins three elements without a serial comma" do
    array = ["one", "two", "three"]
    expect(array.join_and(', ', ' and ', false)).to eq("one, two and three")
  end

  it "keeps duplicate elements" do
    array = ["one", "one", "three"]
    expect(array.join_and).to eq("one, one, and three")
  end

  it "handles multiple true arguments" do
    array = [['one'], ['two'], [], 'four']
    expect(array.that_are(Array, :any?)).to eq([['one'], ['two']])
  end

  it "handles multiple false arguments" do
    array = [['one'], ['two'], '', 'four']
    expect(array.that_are_not(Array, :empty?)).to eq(['four'])
  end
end
