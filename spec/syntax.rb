require "gamefic"
include Gamefic

describe Syntax do
	before :each do
		#@plot = double(Plot)
		#@plot.stub(:syntaxes) { [] }
		#@plot.stub(:add_syntax) {}
	end
	it "finds an action for a valid syntax" do
		syn = Syntax.new nil, "command", :command
		expect(Syntax.match("command", [syn]).length).to eq(1)
	end
	it "finds nothing for an invalid syntax" do
		syn = Syntax.new nil, "command", :command
		expect(Syntax.match("invalid", [syn]).length).to eq(0)	
	end
  it "does not accept extra text sent to a one-word command" do
    plot = Plot.new
    plot.respond :one do |actor|
      actor.tell "ok"
    end
    expect(Syntax.match("one", plot).length).to eq(1)
    expect(Syntax.match("one two", plot).length).to eq(0)
    plot.respond :one, Query::Text.new() do |actor, text|
      actor.tell "ok"
    end
    expect(Syntax.match("one", plot).length).to eq(1)
    expect(Syntax.match("one two", plot).length).to eq(1)
  end 
end
