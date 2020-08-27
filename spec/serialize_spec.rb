describe Gamefic::Serialize do
  before :all do
    @entity = Gamefic::Entity.new
    @index = [@entity]
  end

  it 'serializes arrays' do
    arr1 = [1, 2, 3, @entity]
    ser = arr1.to_serial(@index)
    arr2 = ser.from_serial(@index)
    expect(arr2).to be_a(Array)
    expect(arr1).to eq(arr2)
  end

  it 'serializes sets' do
    set1 = Set.new([1, 2, 3, @entity])
    ser = set1.to_serial(@index)
    set2 = ser.from_serial(@index)
    expect(set2).to be_a(Set)
    expect(set1).to eq(set2)
  end

  it 'serializes hashes' do
    hash1 = { "first" => 1, "second" => @entity, @entity => "third" }
    ser = hash1.to_serial(@index)
    hash2 = ser.from_serial(@index)
    expect(hash2).to be_a(Hash)
    expect(hash1).to eq(hash2)
  end
end
