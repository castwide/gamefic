# frozen_string_literal: true

describe Gamefic::Query::Children do
  it 'finds direct children' do
    context = Gamefic::Entity.new
    child = Gamefic::Entity.new parent: context
    _grandchild = Gamefic::Entity.new parent: child
    matches = Gamefic::Query::Children.new.span(context)
    expect(matches).to eq([child])
  end
end
