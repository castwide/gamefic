require "gamefic"
include Gamefic

describe Syntax do
	before :each do
		@plot = double(Plot)
		@plot.stub(:syntaxes) { [] }
		@plot.stub(:add_syntax) {}
	end
	it "finds an action for a valid syntax" do
		syn = Syntax.new @plot, "command", :command
		Syntax.match("command", [syn]).length.should eq(1)
	end
	it "finds nothing for an invalid syntax" do
		syn = Syntax.new @plot, "command", :command
		Syntax.match("invalid", [syn]).length.should eq(0)	
	end
  it "does not accept extra text sent to a one-word command" do
    plot = Plot.new
    plot.respond :one do |actor|
      actor.tell "ok"
    end
    Syntax.match("one", plot).length.should eq(1)
    Syntax.match("one two", plot).length.should eq(0)
    plot.respond :one, Query::Text.new() do |actor, text|
      actor.tell "ok"
    end
    Syntax.match("one", plot).length.should eq(1)
    Syntax.match("one two", plot).length.should eq(1)
  end 
end
