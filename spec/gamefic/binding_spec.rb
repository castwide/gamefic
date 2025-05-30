# frozen_string_literal: true

describe Gamefic::Binding do
  describe 'registry' do
    it 'pushes an object binding' do
      obj = Object.new
      bin = Object.new
      Gamefic::Binding.push obj, bin
      expect(Gamefic::Binding.for(obj)).to be(bin)
    end

    it 'pops an object binding' do
      obj = Object.new
      bin = Object.new
      Gamefic::Binding.push obj, bin
      Gamefic::Binding.pop obj
      expect(Gamefic::Binding.for(obj)).to be_nil
    end

    it 'deletes empty keys' do
      obj = Object.new
      bin = Object.new
      Gamefic::Binding.push obj, bin
      Gamefic::Binding.pop obj
      expect(Gamefic::Binding.registry[obj]).to be_nil
    end
  end
end
