require 'gamefic'
include Gamefic

describe Query::Base do
  it "finds an object by a word in its name" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'one')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object1)
  end
  it "returns a remainder for an unmatched description" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'three')
    expect(result.objects.length).to eq(0)
    expect(result.remainder).to eq('three')
  end
  it "finds an object by a synonym" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one', :synonyms => 'first primary'
    object2 = plot.make Entity, :name => 'object two', :synonyms => 'second subsequent'
    query = Query::Base.new
    result = query.execute(plot.entities, 'second')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object2)
  end
  it "separates matching text from remainder" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one', :synonyms => 'first primary'
    query = Query::Base.new
    result = query.execute(plot.entities, 'primary object superfluous')
    expect(result.matching_text).to eq('primary object')
    expect(result.remainder).to eq('superfluous')
  end
end

describe Query::Text do
  it "finds a word" do
    query = Query::Text.new('first', 'second', 'third')
    result = query.execute(nil, 'first')
    expect(result.matching_text).to eq('first')
  end
  it "identifies a remainder" do
    query = Query::Text.new('first', 'second', 'third')
    result = query.execute(nil, 'first third fifth')
    expect(result.remainder).to eq('fifth')
  end
end
