require_relative "../lib/gamefic"
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
end
