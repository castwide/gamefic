describe Gamefic::Delegatable::Actions do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) {
    klass = Class.new do
      include Gamefic::Delegatable::Actions
      include Gamefic::Delegatable::Queries
      attr_accessor :rulebook
    end

    klass.new.tap do |obj|
      obj.rulebook = Gamefic::Rulebook.new(stage_func)
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
    expect(object.rulebook.syntaxes.first).to be_a(Gamefic::Syntax)
  end

  it 'creates before actions' do
    object.before_action(:verb1, :verb2) { |_| nil }
    hook = object.rulebook.hooks.before_actions.first
    expect(hook.match?(:verb1)).to be(true)
    expect(hook.match?(:verb3)).to be(false)
  end

  it 'creates after actions' do
    object.after_action(:verb1, :verb2) { |_| nil }
    expect(object.rulebook.hooks.after_actions.first).to be_a(Gamefic::Action::Hook)
    hook = object.rulebook.hooks.after_actions.first
    expect(hook.match?(:verb1)).to be(true)
    expect(hook.match?(:verb3)).to be(false)
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
      dispatcher = Gamefic::Dispatcher.new(actor, [command], object.rulebook.responses)
      dispatcher.proceed.execute
      expect(response).to eq('Just hello')
    end

    it 'raises ArgumentError for invalid arguments' do
      expect { object.respond(:use, nil) {} }.to raise_error(ArgumentError)
    end
  end
end
