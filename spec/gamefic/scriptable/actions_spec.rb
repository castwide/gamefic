describe Gamefic::Delegatable::Actions do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) {
    klass = Class.new do
      include Gamefic::Delegatable::Actions
      include Gamefic::Delegatable::Queries
      attr_accessor :playbook
      define_method(:stage) { |*args, &block| block.call(*args) }
    end

    klass.new.tap do |obj|
      # obj.extend Gamefic::Delegatable::Actions
      obj.playbook = Gamefic::Playbook.new(stage_func)
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
    object.interpret('synonym', 'verb')
    expect(object.playbook.syntaxes.first).to be_a(Gamefic::Syntax)
  end

  it 'raises errors for syntaxes without actions' do
    expect { object.interpret('synonym', 'nonexistent') }.to raise_error(RuntimeError)
  end

  describe '#respond' do
    it 'handles plaintext arguments' do
      response = nil
      object.respond :say, 'hello' do |actor, hello|
        response = "Just #{hello}"
      end
      command = Gamefic::Command.new(:say, ['hello'])
      actor = Gamefic::Actor.new
      dispatcher = Gamefic::Dispatcher.new(actor, [command], object.playbook.responses)
      dispatcher.proceed.execute
      expect(response).to eq('Just hello')
    end

    it 'raises ArgumentError for invalid arguments' do
      expect { object.respond(:use, nil) {} }.to raise_error(ArgumentError)
    end
  end
end
