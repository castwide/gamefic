describe Gamefic::Scriptable::Actions do
  let(:object) {
    klass = Class.new do
      include Gamefic::Scriptable::Actions
      include Gamefic::Scriptable::Queries
      attr_accessor :playbook
    end

    klass.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Actions
      obj.playbook = Gamefic::Playbook.new
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

  it 'creates syntaxes' do
    object.respond(:verb, Gamefic::Entity) { |_, _| nil }
    response = object.interpret('synonym', 'verb')
    expect(response).to be_a(Gamefic::Syntax)
  end

  it 'raises errors for syntaxes without actions' do
    expect { object.interpret('synonym', 'nonexistent') }.to raise_error(RuntimeError)
  end
end
