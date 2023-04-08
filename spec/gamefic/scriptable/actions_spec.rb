describe Gamefic::Scriptable::Actions do
  let(:object) {
    Object.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Actions
    end
  }

  it 'creates responses' do
    response = object.respond(:verb, Gamefic::Entity) { |_, _| nil }
    expect(response).to be(:verb)
  end

  it 'creates meta responses' do
    response = object.meta(:verb, Gamefic::Entity) { |_, _| nil }
    expect(response).to be(:verb)
  end
end
