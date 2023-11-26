describe Gamefic::Scriptable::Actions do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) {
    klass = Class.new do
      include Gamefic::Scriptable::Actions
      include Gamefic::Scriptable::Queries
      attr_accessor :playbook
      define_method(:stage) { |*args, &block| block.call(*args) }
    end

    klass.new.tap do |obj|
      # obj.extend Gamefic::Scriptable::Actions
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
    it 'raises FrozenPlaybookError' do
      object.playbook.freeze

      expect {
        object.respond(:foo) {}
      }.to raise_error(Gamefic::FrozenPlaybookError)
    end
  end

  describe '#meta' do
    it 'raises FrozenPlaybookError' do
      object.playbook.freeze

      expect {
        object.meta(:foo) {}
      }.to raise_error(Gamefic::FrozenPlaybookError)
    end
  end

  describe '#before_action' do
    it 'raises FrozenPlaybookError' do
      object.playbook.freeze

      expect {
        object.before_action {}
      }.to raise_error(Gamefic::FrozenPlaybookError)
    end
  end

  describe '#after_action' do
    it 'raises FrozenPlaybookError' do
      object.playbook.freeze

      expect {
        object.after_action {}
      }.to raise_error(Gamefic::FrozenPlaybookError)
    end
  end
end
