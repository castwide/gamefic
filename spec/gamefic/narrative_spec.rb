describe Gamefic::Narrative do
  describe 'class' do
    it 'adds a script' do
      blk = proc {}
      Gamefic::Narrative.script &blk
      expect(Gamefic::Narrative.blocks).to eq([blk])
    end
  end

  describe 'instance' do
    describe '#initialize' do
      it 'runs scripts' do
        executed = false
        blk = proc { executed = true }
        Gamefic::Narrative.script &blk
        Gamefic::Narrative.new
        expect(executed).to be(true)
      end
    end
  end
end
