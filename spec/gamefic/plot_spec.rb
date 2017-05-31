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
		expect(plot.playbook.actions_for(:mycommand).length).to eq(1)
	end
	it "adds new actions to the list of command words" do
		plot = Plot.new
		plot.respond :mycommand do |actor|
			actor.tell "myresult"
		end
		expect(plot.verbs.include?("mycommand")).to be true
	end
	it "removes destroyed dynamic entities" do
		plot = Plot.new
		plot.ready
		entity = plot.make Entity
		plot.destroy entity
		expect(plot.entities.length).to eq(0)
	end
end
