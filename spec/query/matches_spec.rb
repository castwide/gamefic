describe Gamefic::Query::Matches do
  it "finds a unique match" do
    objects = ['big red dog', 'small gray cat']
    matches = Gamefic::Query::Matches.execute(objects, 'big red')
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to eq('big red dog')
  end

  it "finds duplicate matches" do
    objects = ['big red dog', 'big red car', 'small gray cat']
    matches = Gamefic::Query::Matches.execute(objects, 'big red')
    expect(matches.objects).to eq(['big red dog', 'big red car'])
  end

  it "rejects matches when disallowing remainders" do
    objects = ['big red dog', 'small gray cat']
    matches = Gamefic::Query::Matches.execute(objects, 'big red cat', continued: false)
    expect(matches.objects.length).to eq(0)
  end

  it "finds a match with a remainder" do
    objects = ['big red dog', 'small gray cat']
    matches = Gamefic::Query::Matches.execute(objects, 'big red cat', continued: true)
    expect(matches.objects.length).to eq(1)
    expect(matches.objects[0]).to eq('big red dog')
    expect(matches.remaining).to eq('cat')
  end
end
