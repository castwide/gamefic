# frozen_string_literal: true

describe Gamefic::Scriptable::Queries do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) {
    klass = Class.new do
      include Gamefic::Scriptable::Queries

      def entities
        @entities ||= []
      end
    end

    klass.new.tap do |obj|
      obj.entities.push Gamefic::Entity.new(name: 'parent entity')
      obj.entities.push Gamefic::Entity.new(name: 'entity one', parent: obj.entities.first)
      obj.entities.push Gamefic::Entity.new(name: 'entity two', parent: obj.entities.first)
    end
  }

  describe '#anywhere' do
    it 'returns a general query' do
      query = object.anywhere
      expect(query).to be_a(Gamefic::Query::General)
    end
  end

  describe '#parent' do
    it 'finds a matching parent' do
      query = object.parent
      one = object.entities[1]
      result = query.query(one, 'parent')
      expect(result.match).to be(object.entities.first)
    end

    it 'returns nil without a match' do
      query = object.parent
      one = object.entities[1]
      result = query.query(one, 'wrong')
      expect(result.match).to be(nil)
      expect(result.remainder).to eq('wrong')
    end
  end

  describe '#children' do
    it 'finds a matching child' do
      query = object.children
      parent = object.entities.first
      result = query.query(parent, 'one')
      expect(result.match).to be(object.entities[1])
    end

    it 'finds ambiguous children' do
      query = object.children(ambiguous: true)
      parent = object.entities.first
      result = query.query(parent, 'entity')
      expect(result.match).to eq(object.entities[1..])
    end
  end

  describe '#siblings' do
    it 'finds a matching sibling' do
      query = object.siblings
      one = object.entities[1]
      result = query.query(one, 'two')
      expect(result.match).to be(object.entities[2])
    end

    it 'does not match the subject' do
      query = object.siblings
      one = object.entities[1]
      result = query.query(one, 'one')
      expect(result.match).to be_nil
      expect(result.remainder).to eq('one')
    end
  end

  describe '#myself' do
    it 'matches itself' do
      query = object.myself
      one = object.entities[1]
      result = query.query(one, 'one')
      expect(result.match).to be(one)
    end
  end

  describe '#plaintext' do
    it 'returns a text query' do
      query = object.plaintext
      expect(query).to be_a(Gamefic::Query::Text)
    end
  end
end
