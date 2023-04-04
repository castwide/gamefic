describe Gamefic::Scripting::Actions do
  let(:object) { Object.new.tap { |obj| obj.extend Gamefic::Scripting::Actions } }

  it 'maps classes to responses' do
    response = object.respond(:verb, Gamefic::Entity) { |_, _| nil }
    query = response.queries.first
    expect(query).to be_a(Gamefic::Query::Scoped)
    expect(query.arguments.first).to be(Gamefic::Entity)
  end
end
