describe Syntax do
	it "acceps a valid syntax" do
		syn = Syntax.new "command", :command
		expect(syn.accept? "command" ).to be true
	end
	it "does not accept an invalid syntax" do
		syn = Syntax.new "command", :command
		expect(syn.accept? "invalid" ).to be false
	end
  it "does not accept extra text sent to a one-word command" do
    syn = Syntax.new "one", :one
    expect(syn.accept? "one").to be true
    expect(syn.accept? "one two").to be false
  end
  it "does not accept a command with missing parts" do
    syn = Syntax.new "one :object", "two :object"
    expect(syn.accept? "one").to be false
    expect(syn.accept? "one two").to be true
  end
  it "tokenizes complex phrases" do
    syntax = Syntax.new "get :foo from :bar", "get :foo :bar"
    command = syntax.tokenize("get the one from the two")
    expect(command.verb).to be(:get)
    expect(command.arguments).to eq(['the one', 'the two'])
  end
  it "tokenizes verbs with multiple words" do
    syntax = Syntax.new "put up :thing", "put_up :thing"
    command = syntax.tokenize("put up your dukes")
    expect(command.verb).to be(:put_up)
    expect(command.arguments).to eq(['your dukes'])
  end
  it "tokenizes arguments with multiple words" do
    syntax = Syntax.new "original :foo", "converted :foo"
    command = syntax.tokenize("original one and two")
    expect(command.verb).to be(:converted)
    expect(command.arguments).to eq(['one and two'])
  end
  it "does case-insensitive matches" do
    syn = Syntax.new "foobar", "foobar"
    expect(syn.accept? "foobar").to be true
    expect(syn.accept? "Foobar").to be true
    expect(syn.accept? "FOOBAR").to be true
  end
end
