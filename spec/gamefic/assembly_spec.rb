describe Gamefic::Assembly do
  after :each do
    Gamefic::Assembly.blocks.clear
  end

  describe 'class' do
    it 'adds a script' do
      blk = proc {}
      Gamefic::Assembly.script &blk
      expect(Gamefic::Assembly.blocks).to eq([blk])
    end
  end

  describe 'instance' do
    describe '#initialize' do
      it 'runs scripts' do
        executed = false
        blk = proc { executed = true }
        Gamefic::Assembly.script &blk
        Gamefic::Assembly.new
        expect(executed).to be(true)
      end
    end
  end
end
