# frozen_string_literal: true

describe Gamefic::Query::Family do
  it 'finds extended family' do
    parent = Gamefic::Entity.new name: 'parent'
    context = Gamefic::Entity.new parent: parent, name: 'context'
    sibling = Gamefic::Entity.new parent: parent, name: 'sibling'
    nephew = Gamefic::Entity.new parent: sibling, name: 'nephew'
    child = Gamefic::Entity.new parent: context, name: 'child'
    family = Gamefic::Query::Family.new.span(context)
    expect(family).to eq([parent, child, sibling, nephew])
  end

  it 'rejects inaccessible entities' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    sibling.instance_eval { define_singleton_method(:accessible) { [] } }
    _nephew = Gamefic::Entity.new parent: sibling
    family = Gamefic::Query::Family.new.span(context)
    expect(family).to eq([parent, sibling])
  end
end
