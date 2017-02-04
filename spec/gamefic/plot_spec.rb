require "gamefic"
include Gamefic

describe Plot do
	it "accepts new entities" do
		plot = Plot.new
		plot.make Entity
		expect(plot.entities.length).to eq(1)
	end
	it "accepts new actions" do
		plot = Plot.new
		plot.respond :mycommand do |actor|
		end
		expect(plot.actions_with_verb(:mycommand).length).to eq(1)
	end
	it "adds new actions to the list of command words" do
		plot = Plot.new
		plot.respond :mycommand do |actor|
			actor.tell "myresult"
		end
		expect(plot.commandwords.include?("mycommand")).to eq(true)
	end
	it "removes destroyed entities" do
		plot = Plot.new
		entity = plot.make Entity
		#entity.destroy
		plot.destroy entity
		expect(plot.entities.length).to eq(0)
	end
end
