# frozen_string_literal: true

describe Gamefic::Query::Base do
  it 'sets default precision to zero' do
    base = Gamefic::Query::Base.new
    expect(base.precision).to eq(0)
  end

  it 'calculates precision with classes' do
    base = Gamefic::Query::Base.new(Gamefic::Entity)
    expect(base.precision).to eq(300)
  end

  it 'calculates precision with modules' do
    base = Gamefic::Query::Base.new(Gamefic::Active)
    expect(base.precision).to eq(100)
  end

  it 'calculates precision with symbols' do
    base = Gamefic::Query::Base.new(:valid?)
    expect(base.precision).to eq(1)
  end

  it 'calculates precision with multiple arguments' do
    base = Gamefic::Query::Base.new(:one?, :two?)
    expect(base.precision).to eq(2)
  end
end
