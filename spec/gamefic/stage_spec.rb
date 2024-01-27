describe Gamefic::Stage do
  let(:object) { Object.new }

  it 'accepts new instance variables' do
    Gamefic::Stage.run(object) { @foo = 'foo' }
    expect(object.instance_variable_get(:@foo)).to eq('foo')
  end

  it 'raises on overwriting instance variables' do
    Gamefic::Stage.run(object) { @foo = Object.new }
    expect {
      Gamefic::Stage.run(object) { @foo = Object.new }
    }.to raise_error(RuntimeError)
  end

  it 'allows overwriting mutable values' do
    Gamefic::Stage.run(object) do
      @boolean = true
      @float = 1.0
      @number = 1
      @string = '1'
      @symbol = :one
    end
    expect {
      Gamefic::Stage.run(object) do
        @boolean = false
        @float = 2.0
        @number = 2
        @string = '2'
        @symbol = :two
      end
    }.not_to raise_error
  end
end
