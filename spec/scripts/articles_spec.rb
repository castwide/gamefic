describe 'Articles' do
  before :all do
    @plot = Gamefic::Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'articles'
    @plot.stage do
      @thing = make Gamefic::Entity, name: 'thing'
      @smith = make Gamefic::Entity, name: 'John Smith', proper_named: true
    end
  end

  it "applies a definite article to an object" do
    expect(@plot.stage { "#{the @thing}" }).to eq 'the thing'
    expect(@plot.stage { "#{The @thing}" }).to eq 'The thing'
  end

  it "applies an indefinite article to an object" do
    expect(@plot.stage { "#{a @thing}" }).to eq 'a thing'
    expect(@plot.stage { "#{A @thing}" }).to eq 'A thing'
  end

  it "ignores articles for proper names" do
    expect(@plot.stage { "#{a @smith}" }).to eq 'John Smith'
    expect(@plot.stage { "#{A @smith}" }).to eq 'John Smith'
    expect(@plot.stage { "#{the @smith}" }).to eq 'John Smith'
    expect(@plot.stage { "#{The @smith}" }).to eq 'John Smith'
  end
end
