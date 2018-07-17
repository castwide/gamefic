include Gamefic

describe Keywords do
  before :all do
    @string = 'big red dog'
    @string.extend Keywords
  end

  it "matches exact phrase" do
    expect(@string.specified?('big red dog')).to be(true)
  end

  it "matches distinct words" do
    expect(@string.specified?('big')).to be(true)
    expect(@string.specified?('red dog')).to be(true)
    @string.specified?('big dog')
    expect(@string.specified?('big dog')).to be(true)
  end

  it "matches partial (fuzzy) words" do
    expect(@string.specified?('bi', fuzzy: true)).to be(true)
    expect(@string.specified?('do', fuzzy: true)).to be(true)
  end

  it "rejects unmatched words" do
    expect(@string.specified?('small red dog')).to be(false)
  end
end
