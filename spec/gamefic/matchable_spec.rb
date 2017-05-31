include Gamefic

describe Matchable do
  before :all do
    @string = 'big red dog'
    @string.extend Matchable
  end

  it "matches exact phrase" do
    expect(@string.match?('big red dog')).to be(true)
  end

  it "matches distinct words" do
    expect(@string.match?('big')).to be(true)
    expect(@string.match?('red dog')).to be(true)
    expect(@string.match?('big dog')).to be(true)
  end

  it "matches partial (fuzzy) words" do
    expect(@string.match?('bi', fuzzy: true)).to be(true)
    expect(@string.match?('do', fuzzy: true)).to be(true)
  end

  it "rejects unmatched words" do
    expect(@string.match?('small red dog')).to be(false)
  end
end
