require "gamefic"
include Gamefic

describe Syntax do
	it "finds an action for a valid syntax" do
		syn = Syntax.new nil, "command", :command
		expect(Syntax.tokenize("command", [syn]).length).to eq(1)
	end
	it "finds nothing for an invalid syntax" do
		syn = Syntax.new nil, "command", :command
		expect(Syntax.tokenize("invalid", [syn]).length).to eq(0)	
	end
  it "does not accept extra text sent to a one-word command" do
    plot = Plot.new
    plot.respond :one do |actor|
      actor.tell "ok"
    end
    expect(Syntax.tokenize("one", plot.syntaxes).length).to eq(1)
    expect(Syntax.tokenize("one two", plot.syntaxes).length).to eq(0)
    plot.respond :one, Query::Text.new() do |actor, text|
      actor.tell "ok"
    end
    expect(Syntax.tokenize("one", plot.syntaxes).length).to eq(1)
    expect(Syntax.tokenize("one two", plot.syntaxes).length).to eq(1)
  end
  it "passes the remainder of an argument to the next argument" do
    plot = Plot.new
    item = nil
    plot.respond :combine, Query.siblings do |actor, i1|
      item = i1
    end
    plot.respond :combine, Query.siblings, Query.siblings do |actor, i1, i2|
      item = [i1, i2]
    end
    room = plot.make Room, :name => "room"
    foo = plot.make Entity, :name => "foo", :parent => room
    bar = plot.make Entity, :name => "bar", :parent => room
    character = plot.make Character, :name => "character", :parent => room
    character.perform "combine foo"
    expect(item).to eq(foo)
    character.perform "combine bar"
    expect(item).to eq(bar)
    character.perform "combine foo bar"
    expect(item).to eq([foo, bar])
  end
  it "does case-insensitive matches" do
    plot = Plot.new
    done = false
    plot.respond :foobar do |actor|
      done = true
    end
    character = plot.make Character, :name => 'character'
    character.perform "foobar"
    expect(done).to eq(true)
    done = false
    character.perform "FOOBAR"
    expect(done).to eq(true)
  end
end
