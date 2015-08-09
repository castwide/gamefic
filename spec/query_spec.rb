require 'gamefic'
include Gamefic

module LastOrderTest
  attr_accessor :last_order
end

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
  it "checks for an exact match in a subquery for prepositional phrases" do
    plot = Plot.new
    table = plot.make Entity, :name => 'the table'
    book1 = plot.make Entity, :name => 'a book', :parent => table
    book2 = plot.make Entity, :name => 'a book'
    query = Query::Base.new
    result = query.execute(plot.entities, 'book')
    expect(result.objects.length).to eq(2)
    result = query.execute(plot.entities, 'book on table')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(book1)
  end
  it "recognizes \"it\" as the object of the last order" do
    plot = Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    array = plot.entities
    array.extend LastOrderTest
    array.last_order = Gamefic::Director::Order.new(nil, nil, [object1])
    query = Query::Base.new
    result = query.execute(array, 'it')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object1)
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
