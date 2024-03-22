# frozen_string_literal: true

describe Gamefic::Matcher do
  let(:plot) {
    klass = Class.new(Gamefic::Plot) do
      seed do
        @room = make Gamefic::Entity, name: 'room'
        @thing = make Gamefic::Entity, name: 'thing', parent: @room
        @hidden = make Gamefic::Entity, name: 'hidden'
      end

      script do
        respond(:look, available) { |_, _| }
        respond(:use, @thing) { |_, _| }
        respond(:say, plaintext) { |_, _| }
        respond(:look, 'around') { |_, _| }

        introduction do |actor|
          actor.parent = @room
        end
      end
    end
    klass.new
  }

  let(:actor) { plot.introduce }

  before(:each) { plot.ready }

  it 'matches strict available entities' do
    expressions = Gamefic::Syntax.tokenize('look thing', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq([plot.pick('thing')])
  end

  it 'matches fuzzy available entities' do
    expressions = Gamefic::Syntax.tokenize('look thi', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq([plot.pick('thing')])
  end

  it 'does not match unavailable entities' do
    expressions = Gamefic::Syntax.tokenize('look hidden', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be_nil
    expect(command.arguments).to be_empty
  end

  it 'matches exact text' do
    expressions = Gamefic::Syntax.tokenize('look around', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq(['around'])
  end

  it 'does not match text with remainder' do
    expressions = Gamefic::Syntax.tokenize('look around here', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be_nil
    expect(command.arguments).to be_empty
  end

  it 'matches freeform text' do
    expressions = Gamefic::Syntax.tokenize('say hello world', plot.rulebook.syntaxes)
    command = Gamefic::Matcher.match(actor, expressions)
    expect(command.verb).to be(:say)
    expect(command.arguments).to eq(['hello world'])
  end
end
