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

  describe '#call' do
    it 'delegates bound methods' do
      klass = Class.new(Gamefic::Narrative) do
        bind def binding_works
          'working'
        end
      end

      narr = klass.new
      code = proc { binding_works }
      binding = Gamefic::Binding.new(narr, code)
      expect(binding.call).to be('working')
    end
  end
end
