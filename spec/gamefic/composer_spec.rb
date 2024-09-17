# frozen_string_literal: true

describe Gamefic::Composer do
  let(:plot) {
    klass = Class.new(Gamefic::Plot) do
      seed do
        @room = make Gamefic::Entity, name: 'room'
        @thing = make Gamefic::Entity, name: 'thing', parent: @room
        @thingamabob = make Gamefic::Entity, name: 'thingamabob', parent: @room
        @hidden = make Gamefic::Entity, name: 'hidden'
      end

      script do
        respond(:look, available) {}
        respond(:use, @thingamabob) {}
        respond(:use, @thing) {}
        respond(:say, plaintext) {}
        respond(:look, 'around') {}
        respond(:use, plaintext) {}

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
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq([plot.pick('thing')])
  end

  it 'matches fuzzy available entities' do
    expressions = Gamefic::Syntax.tokenize('look thinga', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq([plot.pick('thingamabob')])
  end

  it 'does not match unavailable entities' do
    expressions = Gamefic::Syntax.tokenize('look hidden', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be_nil
    expect(command.arguments).to be_empty
  end

  it 'matches exact text' do
    expressions = Gamefic::Syntax.tokenize('look around', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be(:look)
    expect(command.arguments).to eq(['around'])
  end

  it 'does not match text with remainder' do
    expressions = Gamefic::Syntax.tokenize('look around here', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be_nil
    expect(command.arguments).to be_empty
  end

  it 'matches freeform text' do
    expressions = Gamefic::Syntax.tokenize('say hello world', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be(:say)
    expect(command.arguments).to eq(['hello world'])
  end

  it 'prioritizes precision with fuzzy matches' do
    expressions = Gamefic::Syntax.tokenize('use thinga', plot.rulebook.syntaxes)
    command = Gamefic::Composer.compose(actor, expressions)
    expect(command.verb).to be(:use)
    expect(command.arguments).to eq([plot.pick!('thingamabob')])
  end
end
