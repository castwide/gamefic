# frozen_string_literal: true

describe Gamefic::Query::Scoped do
  it 'returns match in scope' do
    scoped = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
    parent = Gamefic::Entity.new
    actor = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent, name: 'sibling'
    result = scoped.query(actor, 'sibling')
    expect(result.match).to be(sibling)
  end

  it 'return nil for unmatched objects' do
    scoped = Gamefic::Query::Scoped.new(Gamefic::Scope::Family)
    parent = Gamefic::Entity.new
    actor = Gamefic::Entity.new parent: parent
    Gamefic::Entity.new parent: parent, name: 'right'
    result = scoped.query(actor, 'wrong')
    expect(result.match).to be_nil
  end
end
