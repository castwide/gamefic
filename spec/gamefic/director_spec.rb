describe Gamefic::Director do
  it 'raises an error for undelegated methods' do
    director = Gamefic::Director.new(nil, [])
    expect { director.nomethod }.to raise_error(NoMethodError)
  end
end
