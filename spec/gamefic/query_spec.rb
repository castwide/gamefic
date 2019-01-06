module LastObjectTest
  attr_accessor :last_object
end

# @todo This is likely to be deprecated, with a directory of query specs to replace it.

=begin
describe Query::Base do
  it "finds an object by a word in its name" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'one')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object1)
  end
  it "returns a remainder for an unmatched description" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    query = Query::Base.new
    result = query.execute(plot.entities, 'three')
    expect(result.objects.length).to eq(0)
    expect(result.remainder).to eq('three')
  end
  it "finds an object by a synonym" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one', :synonyms => 'first primary'
    object2 = plot.make Entity, :name => 'object two', :synonyms => 'second subsequent'
    query = Query::Base.new
    result = query.execute(plot.entities, 'second')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object2)
  end
  it "separates matching text from remainder" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one', :synonyms => 'first primary'
    query = Query::Base.new
    result = query.execute(plot.entities, 'primary object superfluous')
    expect(result.matching_text).to eq('primary object')
    expect(result.remainder).to eq('superfluous')
  end
  it "checks for an exact match in a subquery for prepositional phrases" do
    plot = Gamefic::Plot.new
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
  it "recognizes \"it\" as the last object of the caller" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    array = plot.entities
    array.extend LastObjectTest
    array.last_object = object1
    query = Query::Base.new
    result = query.execute(array, 'it')
    expect(result.objects.length).to eq(1)
    expect(result.objects[0]).to eq(object1)
  end
  it "uses conjunctions to add more entities to matches" do
    plot = Gamefic::Plot.new
    object1 = plot.make Entity, :name => 'object one'
    object2 = plot.make Entity, :name => 'object two'
    array = plot.entities
    query = Query::Base.new
    result = query.execute(array, 'one')
    expect(result.objects.length).to eq(1)
    result = query.execute(array, 'two')
    expect(result.objects.length).to eq(1)
    result = query.execute(array, 'one two')
    expect(result.objects.length).to eq(1)
    result = query.execute(array, 'one and two')
    expect(result.objects.length).to eq(2)
    result = query.execute(array, 'one, two')
    expect(result.objects.length).to eq(2)
  end
  it "requires at least three characters for a partial match" do
    plot = Gamefic::Plot.new
    entity = plot.make Entity, :name => 'dictionary'
    query = Query::Base.new
    matches = query.match('di', [entity])
    expect(matches.objects.length).to eq(0)
    matches = query.match('dic', [entity])
    expect(matches.objects.length).to eq(1)    
  end
  it "does case-insensitive matching" do
    plot = Gamefic::Plot.new
    entity = plot.make Entity, :name => 'dictionary'
    query = Query::Base.new
    matches = query.match('dictionary', [entity])
    expect(matches.objects.length).to eq(1)
    matches = query.match('DICTIONARY', [entity])
    expect(matches.objects.length).to eq(1)        
  end
  it "matches a set of many that includes a child reference" do
    item1 = Entity.new name: 'item one'
    item2 = Entity.new name: 'item two'
    parent = Entity.new name: 'parent'
    item3 = Entity.new name: 'item three', parent: parent
    query = Query::Base.new
    matches = query.match("one, item in parent and two", [item1, item2, item3, parent])
    flat = matches.objects.flatten
    expect(flat.include?(item1)).to eq(true)
    expect(flat.include?(item2)).to eq(true)
    expect(flat.include?(item3)).to eq(true)
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
=end
