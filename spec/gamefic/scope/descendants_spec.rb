# frozen_string_literal: true

describe Gamefic::Scope::Descendants do
  it 'finds extended family' do
    parent = Gamefic::Entity.new name: 'parent'
    context = Gamefic::Entity.new parent: parent, name: 'context'
    sibling = Gamefic::Entity.new parent: parent, name: 'sibling'
    _nephew = Gamefic::Entity.new parent: sibling, name: 'nephew'
    child = Gamefic::Entity.new parent: context, name: 'child'
    grandchild = Gamefic::Entity.new parent: child, name: 'grandchild'
    descendants = Gamefic::Scope::Descendants.matches(context)
    expect(descendants).to eq([child, grandchild])
  end

  it 'rejects inaccessible entities' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent, name: 'context'
    child = Gamefic::Entity.new parent: context, name: 'child'
    child.instance_eval { define_singleton_method(:accessible?) { false} }
    _grandchild = Gamefic::Entity.new parent: child, name: 'grandchild'
    descendants = Gamefic::Scope::Descendants.matches(context)
    expect(descendants).to eq([child])
  end
end
