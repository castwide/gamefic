describe Gamefic::Scriptable::Actions do
  let(:object) {
    Object.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Actions
      # @todo Module expects #setup to exist. Is there a better way to do this?
      obj.define_singleton_method(:setup) { Gamefic::Setup.new }
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
