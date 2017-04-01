describe Plot::Articles do
  let(:container_class) {
    Class.new do
      include Plot::Articles
    end
  }
  let(:described_class) {
    Class.new do
      include Describable
    end
  }
  it "applies a definite article to an object" do
    container = container_class.new
    described = described_class.new
    described.name = "a thing"
    expect(container.the described).to eq 'the thing'
    expect(container.The described).to eq 'The thing'
  end
  it "applies an indefinite article to an object" do
    container = container_class.new
    described = described_class.new
    described.name = "the thing"
    expect(container.a described).to eq 'a thing'
    expect(container.A described).to eq 'A thing'
  end
  it "ignores articles for proper names" do
    container = container_class.new
    described = described_class.new
    described.name = "John Smith"
    described.proper_named = true
    expect(container.a described).to eq 'John Smith'
    expect(container.A described).to eq 'John Smith'
  end
end
