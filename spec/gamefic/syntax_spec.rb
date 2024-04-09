# frozen_string_literal: true

describe Gamefic::Syntax do
  it "acceps a valid syntax" do
    syn = Gamefic::Syntax.new "command", "command"
    expect(syn.accept? "command" ).to be true
  end

  it "does not accept an invalid syntax" do
    syn = Gamefic::Syntax.new "command", "command"
    expect(syn.accept? "invalid" ).to be false
  end

  it "does not accept extra text sent to a one-word command" do
    syn = Gamefic::Syntax.new "one", "one"
    expect(syn.accept? "one").to be true
    expect(syn.accept? "one two").to be false
  end

  it "does not accept a command with missing parts" do
    syn = Gamefic::Syntax.new "one :object", "two :object"
    expect(syn.accept? "one").to be false
    expect(syn.accept? "one two").to be true
  end

  it "tokenizes complex phrases" do
    syntax = Gamefic::Syntax.new "get :foo from :bar", "get :foo :bar"
    expression = syntax.tokenize("get the one from the two")
    expect(expression.verb).to be(:get)
    expect(expression.tokens).to eq(['the one', 'the two'])
  end

  it "tokenizes verbs with multiple words" do
    syntax = Gamefic::Syntax.new "put up :thing", "put_up :thing"
    expression = syntax.tokenize("put up your dukes")
    expect(expression.verb).to be(:put_up)
    expect(expression.tokens).to eq(['your dukes'])
  end

  it "tokenizes tokens with multiple words" do
    syntax = Gamefic::Syntax.new "original :foo", "converted :foo"
    expression = syntax.tokenize("original one and two")
    expect(expression.verb).to be(:converted)
    expect(expression.tokens).to eq(['one and two'])
  end

  it "does case-insensitive matches" do
    syn = Gamefic::Syntax.new "foobar", "foobar"
    expect(syn.accept? "foobar").to be true
    expect(syn.accept? "Foobar").to be true
    expect(syn.accept? "FOOBAR").to be true
  end

  it "tokenizes syntaxes that switch from opening argument to command" do
    syntax = Gamefic::Syntax.new ":vendor make :product", "order :vendor :product"
    expression = syntax.tokenize('bob make cookies')
    expect(expression.verb).to eq(:order)
    expect(expression.tokens).to eq(['bob', 'cookies'])
  end

  it "tokenizes syntaxes that have commands without opening verbs" do
    syntax = Gamefic::Syntax.new ":vendor make :product", ":vendor manufacture :product"
    expression = syntax.tokenize('bob make cookies')
    expect(expression.verb).to eq(nil)
    expect(expression.tokens).to eq(['bob', 'manufacture', 'cookies'])
  end

  it 'equals other based on signature' do
    s1 = Gamefic::Syntax.new 'make :a from :b', 'make :a :b'
    s2 = Gamefic::Syntax.new 'make :x from :y', 'make :x :y'
    expect(s1).to eq(s2)
  end

  it 'does not equal other based on words in signature' do
    s1 = Gamefic::Syntax.new 'make :a from :b', 'make :a :b'
    s2 = Gamefic::Syntax.new 'make :x out of :y', 'make :x :y'
    expect(s1).not_to eq(s2)
  end

  it 'does not equal other based on verbs' do
    s1 = Gamefic::Syntax.new 'make :a from :b', 'make :a :b'
    s2 = Gamefic::Syntax.new 'make :x from :y', 'manufacture :x :y'
    expect(s1).not_to eq(s2)
  end

  it 'tokenizes commands from an array of syntaxes' do
    s2 = Gamefic::Syntax.new 'make :x :y', 'make :x :y'
    s1 = Gamefic::Syntax.new 'make :a from :b', 'make :a :b'
    s4 = Gamefic::Syntax.new 'use :x :y', 'use :x :y'
    s3 = Gamefic::Syntax.new 'use :x on :y', 'use :x :y'
    expressions = Gamefic::Syntax.tokenize 'make thing from material', [s1, s2, s3, s4]
    expect(expressions.map(&:verb)).to eq([:make, :make])
    expect(expressions.first.tokens).to eq(['thing', 'material'])
    expect(expressions.last.tokens).to eq(['thing from material', nil])
  end

  it 'validates command parameters' do
    expect {
      Gamefic::Syntax.new('make', 'make :thing')
    }.to raise_error(ArgumentError)
  end
end
