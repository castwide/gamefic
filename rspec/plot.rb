require_relative "../lib/gamefic"
include Gamefic

describe Plot do
	it "accepts new entities" do
		plot = Plot.new
		plot.make Entity
		plot.entities.length.should eq(1)
	end
	it "accepts new actions" do
		plot = Plot.new
		plot.respond :mycommand do |actor|
		end
		plot.commands[:mycommand].length.should eq(1)
	end
	it "adds new actions to the list of command words" do
		plot = Plot.new
		plot.respond :mycommand do |actor|
			actor.tell "myresult"
		end
		plot.commandwords.include?("mycommand").should eq(true)
	end
	it "removes destroyed entities" do
		plot = Plot.new
		entity = plot.make Entity
		entity.destroy
		plot.entities.length.should eq(0)
	end
end
