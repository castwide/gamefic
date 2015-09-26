describe "Reachable Query" do
  it "does not include the subject" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([])    
  end
  it "includes all siblings" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item = plot.make Item, :name => 'item', :parent => room
    thing = plot.make Thing, :name => 'thing', :parent => room
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([item, thing])
  end
  it "includes children of open containers" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    container = plot.make Container, :name => 'container', :parent => room
    container.open = true
    item = plot.make Item, :name => 'item', :parent => container
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([container, item])  
  end
  it "does not include children of closed containers" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    container = plot.make Container, :name => 'container', :parent => room
    item = plot.make Item, :name => 'item', :parent => container
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([container])
  end
  it "includes children of supporters" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    supporter = plot.make Supporter, :name => 'supporter', :parent => room
    item = plot.make Item, :name => 'item', :parent => supporter
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([supporter, item])
  end
end