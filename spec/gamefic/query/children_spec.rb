# frozen_string_literal: true

describe Gamefic::Query::Children do
  it 'finds children and accessible descendants' do
    context = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: context
    grandchild = Gamefic::Entity.new parent: child
    matches = Gamefic::Query::Children.new.span(context)
    expect(matches).to eq([child, grandchild])
  end

  it 'rejects inaccessible descendants' do
    context = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: context
    child.instance_eval { define_singleton_method(:accessible?) { false } }
    _grandchild = Gamefic::Entity.new parent: child
    matches = Gamefic::Query::Children.new.span(context)
    expect(matches).to eq([child])
  end
end