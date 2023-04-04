# frozen_string_literal: true

describe Gamefic::Scope::Siblings do
  it 'finds siblings' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    result = Gamefic::Scope::Siblings.matches(context)
    expect(result).to eq([sibling])
  end
end
