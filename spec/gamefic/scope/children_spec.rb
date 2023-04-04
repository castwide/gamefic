# frozen_string_literal: true

describe Gamefic::Scope::Children do
  it 'finds children and accessible descendants' do
    context = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: context
    grandchild = Gamefic::Entity.new parent: child
    matches = Gamefic::Scope::Children.matches(context)
    expect(matches).to eq([child, grandchild])
  end

  it 'rejects inaccessible descendants' do
    context = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: context
    child.instance_eval { define_singleton_method(:accessible?) { false } }
    grandchild = Gamefic::Entity.new parent: child
    matches = Gamefic::Scope::Children.matches(context)
    expect(matches).to eq([child])
  end
end
