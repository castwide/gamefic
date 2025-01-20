# frozen_string_literal: true

describe Gamefic::Scriptable::Queries do
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
      obj.entities.push Gamefic::Entity.new(name: 'grandchild', parent: obj.entities.first.children.first)
    end
  }

  describe '#anywhere' do
    it 'returns a general query' do
      query = object.anywhere
      expect(query).to be_a(Gamefic::Query::Global)
    end
  end

  describe '#parent' do
    it 'finds a matching parent' do
      query = object.parent
      one = object.entities[1]
      result = query.filter(one, 'parent')
      expect(result.match).to be(object.entities.first)
    end

    it 'returns nil without a match' do
      query = object.parent
      one = object.entities[1]
      result = query.filter(one, 'wrong')
      expect(result.match).to be(nil)
      expect(result.remainder).to eq('wrong')
    end
  end

  describe '#children' do
    it 'finds a matching child' do
      query = object.children
      parent = object.entities.first
      result = query.filter(parent, 'one')
      expect(result.match).to be(object.entities[1])
    end
  end

  describe '#descendants' do
    it 'finds matching descendants' do
      query = object.descendants
      parent = object.entities.first
      expect(query.span(parent).sort_by(&:name)).to eq(object.entities[1..].sort_by(&:name))
    end
  end

  describe '#siblings' do
    it 'finds a matching sibling' do
      query = object.siblings
      one = object.entities[1]
      result = query.filter(one, 'two')
      expect(result.match).to be(object.entities[2])
    end

    it 'does not match the subject' do
      query = object.siblings
      one = object.entities[1]
      result = query.filter(one, 'one')
      expect(result.match).to be_nil
      expect(result.remainder).to eq('one')
    end
  end

  describe '#extended' do
    it "finds matching siblings and siblings' descendants" do
      parent = object.entities.first
      subject, sibling = parent.children
      sibling_child = Gamefic::Entity.new(name: 'sibling child', parent: sibling)
      result = object.extended.span(subject)
      expect(result).to eq([sibling, sibling_child])
    end
  end

  describe '#myself' do
    it 'matches itself' do
      query = object.myself
      one = object.entities[1]
      result = query.filter(one, 'one')
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
