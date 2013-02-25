require "rubygems"
require "json"
require "libx/graphical"

action "^map".to_sym do |actor|
	actor.tell "/ #{actor.parent.image}"
	actor.parent.children.that_are(Fixture).each { |child|
		x ={}
		x[:name] = child.name
		x[:command] = child.map_command
		x[:image] = child.image
		x[:uid] = child.uid
		x[:set] = 'F'
		actor.tell "* #{JSON.generate(x)}"
	}
	actor.parent.children.that_are(Itemized).that_are_not(Fixture).each { |child|
		x ={}
		x[:name] = child.name
		x[:command] = child.map_command
		x[:image] = child.image
		x[:uid] = child.uid
		x[:set] = 'I'
		actor.tell "* #{JSON.generate(x)}"
	}
	actor.parent.children.that_are(Character).that_are_not(actor).each { |child|
		x ={}
		x[:name] = child.name
		x[:command] = child.map_command
		x[:image] = child.image
		x[:uid] = child.uid
		x[:set] = 'C'
		actor.tell "* #{JSON.generate(x)}"
	}
	actor.parent.children.that_are(Portal).each { |child|
		x ={}
		x[:name] = child.name
		x[:command] = child.map_command
		x[:image] = child.image
		x[:uid] = child.uid
		x[:set] = 'P'
		actor.tell "| #{JSON.generate(x)}"
	}
	actor.tell "* 0"
end

action "^look".to_sym, query(:string) do |actor, string|
	actor.tell "+--"
	actor.inject "look #{string}"
	actor.tell "---"
end

action "^look".to_sym, query(:siblings, Portable) do |actor, item|
	actor.tell "+--"
	actor.inject "look #{item.uid}"
	actor.tell "`take #{item.uid}` (Take #{item.longname})"
	actor.tell "---"
end

action "^look".to_sym, query(:children) do |actor, item|
	actor.tell "+--"
	actor.inject "look #{item.uid}"
	actor.tell "`drop #{item.uid}` (Drop #{item.longname})"
	actor.tell "---"
end

action "^search".to_sym, query(:family, Container) do |actor, container|
	if container.children.length == 0
		actor.tell "+--"
		actor.tell "You don't find anything."
		actor.tell "---"
	else
		x = {}
		x[:name] = container.longname
		x[:image] = container.image
		x[:class] = Container
		x[:description] = container.description
		x[:options] = Array.new
		container.children.that_are(Itemized).each { |child|
			opt = {}
			opt[:text] = child.name
			opt[:command] = "^look at #{child.uid} in #{container.uid}"
			opt[:image] = ""
			x[:options].push opt
		}
		actor.tell "$ #{JSON.generate(x)}"
	end
end

action "^inventory".to_sym do |actor|
	actor.tell "+--"
	if (actor.children.length == 0)
		actor.tell "You're not carrying anything."
	else
		actor.tell "+--"
		actor.tell "# You are carrying:"
		actor.children.that_are(Itemized).each { |child|
			actor.tell "`^look #{child.uid}` (#{child.longname})"
		}
	end
	actor.tell "---"
end

action "^look_in_at".to_sym, query(:family, Container), subquery(:children, Item) do |actor, container, item|
	x = {}
	x[:name] = item.longname
	x[:image] = ""
	x[:class] = Item
	x[:description] = item.description
	x[:options] = [
		{ :text => "Take #{item}", :command => "take #{item.uid} from #{container.uid}" }
	]
	actor.tell "$ #{JSON.generate(x)}"
end
instruct "^look at [item] in [container]", "^look_in_at".to_sym, "[container] [item]"
instruct "^look [item] in [container]", "^look_in_at".to_sym, "[container] [item]"

action "^ask".to_sym, query(:string) do |actor, string|
	actor.tell "+--"
	actor.inject "ask #{string}"
	actor.tell "---"
end

action "^gconv".to_sym do |actor|
	words = Array.new
	actor.root.commandwords.each { |w|
		if (w[0, 1] == '^')
			words.push(w[1, w.length])
		end
	}
	actor.tell "^^ #{words.join(' ')}"
end

action "^look".to_sym do |actor|
	actor.tell "+--"
	actor.inject "look"
	actor.tell "---"
end

instruct "^look at [item]", "^look".to_sym, "[item]"
