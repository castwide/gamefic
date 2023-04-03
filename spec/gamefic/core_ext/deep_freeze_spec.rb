RSpec.describe '#deep_freeze' do
  context 'with instance variables' do
    let(:klass) {
      Class.new do
        attr_accessor :name
      end
    }

    it 'freezes the object' do
      obj = klass.new
      obj.deep_freeze
      expect(obj).to be_frozen
    end

    it 'freezes the instance variables' do
      obj = klass.new
      obj.name = 'Bob'
      obj.deep_freeze
      expect(obj.name).to be_frozen
    end

    it 'raises errors on write' do
      obj = klass.new
      obj.name = 'Bob'
      obj.deep_freeze
      expect { obj.name = 'Joe' }.to raise_error(FrozenError)
    end

    it 'raises errors on mutation' do
      obj = klass.new
      obj.name = 'Bob'
      obj.deep_freeze
      expect { obj.name.upcase! }.to raise_error(FrozenError)
    end

    it 'avoids infinite recursion' do
      obj = klass.new
      obj.name = obj
      expect { obj.deep_freeze }.not_to raise_error
    end
  end

  context 'with enumerables' do
    let(:klass) {
      Class.new do
        def array
          @array ||= []
        end

        def hash
          @hash ||= {}
        end
      end
    }

    it 'freezes entries' do
      obj = klass.new
      obj.array.concat ['Bob', 'Joe', 'Kim']
      obj.hash.merge!({
        'Bob' => [1, 2, 3],
        'Joe' => [4, 5, 6]
      })
      obj.deep_freeze
      expect(obj.array).to be_frozen
      expect(obj.array.all?(&:frozen?)).to be(true)
      expect(obj.hash).to be_frozen
      expect(obj.hash.keys.all?(&:frozen?)).to be(true)
      expect(obj.hash.values.all?(&:frozen?)).to be(true)
    end

    it 'raises errors on mutation' do
      obj = klass.new
      obj.array.concat ['Bob', 'Joe', 'Kim']
      obj.hash.merge!({
        'Bob' => 'Jones',
        'Joe' => 'Smith',
        'Kim' => 'Henry'
      })
      obj.deep_freeze

      expect { obj.array.first.upcase! }.to raise_error(FrozenError)
      expect { obj.hash['Bob'].upcase! }.to raise_error(FrozenError)
      expect { obj.hash.merge!({ 'Larry' => 'Error' }) }.to raise_error(FrozenError)
    end

    it 'avoids infinite recursion' do
      obj = klass.new
      obj.array.push obj
      expect { obj.deep_freeze }.not_to raise_error
    end
  end
end
