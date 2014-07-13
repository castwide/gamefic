require 'gamefic'
include Gamefic

describe Query::Base do
  it "finds an object by a word in its name" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'one')
    result.objects.length.should eq(1)
    result.objects[0].should eq(object1)
  end
  it "returns a remainder for an unmatched description" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'three')
    result.objects.length.should eq(0)
    result.remainder.should eq('three')
  end
  it "finds an object by a synonym" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one', :synonyms => 'first primary'
    object2 = plot.make Entity, :name => 'object two', :synonyms => 'second subsequent'
    query = Query::Base.new
    result = query.execute(plot.entities, 'second')
    result.objects.length.should eq(1)
    result.objects[0].should eq(object2)
  end
end

describe Query::Text do
  it "finds a word" do
    query = Query::Text.new('first', 'second', 'third')
    result = query.execute(nil, 'first')
    result.matching_text.should eq('first')
  end
end
