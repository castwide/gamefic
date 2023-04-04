# frozen_string_literal: true

describe Gamefic::Scope::Family do
  it 'finds extended family' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    nephew = Gamefic::Entity.new parent: sibling
    family = Gamefic::Scope::Family.matches(context)
    expect(family).to eq([parent, sibling, nephew])
  end

  it 'rejects inaccessible entities' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    sibling.instance_eval { define_singleton_method(:accessible?) { false} }
    _nephew = Gamefic::Entity.new parent: sibling
    family = Gamefic::Scope::Family.matches(context)
    expect(family).to eq([parent, sibling])
  end
end
