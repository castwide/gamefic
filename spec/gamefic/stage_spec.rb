describe Gamefic::Stage do
  let(:object) { Object.new }

  it 'copies instance variables' do
    Gamefic::Stage.set(object) { @foo = 'foo' }
    expect(object.instance_variable_get(:@foo)).to eq('foo')
  end

  it 'raises on overwriting instance variables' do
    Gamefic::Stage.set(object) { @foo = Object.new }
    expect {
      Gamefic::Stage.set(object) { @foo = Object.new }
    }.to raise_error(RuntimeError)
  end

  it 'allows overwriting mutable values' do
    Gamefic::Stage.set(object) do
      @boolean = true
      @float = 1.0
      @number = 1
      @string = '1'
      @symbol = :one
    end
    expect {
      Gamefic::Stage.set(object) do
        @boolean = false
        @float = 2.0
        @number = 2
        @string = '2'
        @symbol = :two
      end
    }.not_to raise_error
  end
end
