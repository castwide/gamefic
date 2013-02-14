theater.scaffold("theaters/test.rb")

introduction do
	player.tell "Welcome to the game!"
	player.parent = entity(:room)
end

scene :interlude do
	player.tell "Romantic interlude."
	player.tell "Also, #{entity(:johnboy).name}"
end

prop :room, Room do |room|
	room.name = "A room"
	room.description = "You're in a room."
end

prop :johnboy, Character do |prop|
	prop.name = "John Boy"
end

prop :walking_stick, Entity

action :go, ANYWHERE.reduce(Portal) do |actor, portal|
	actor.tell "This is where you'd move."
end

action :go do |actor|
	actor.tell "This is when you'd go somewhere."
	cue :interlude
	conclude :happy
end

action :look, STRING do |actor, string|
	actor.tell "You're looking at something?"
	passthru
end

action :look do |actor|
	actor.tell actor.parent.description
end

action :teleport do |actor|
	actor.parent = entity(:office)
	actor.tell "You teleport to your office."
end

conclusion :happy do
	player.tell "You win!"
end

instruct "go to [place]", :go, "[place]"
instruct "go to [place]", :drive, "car [place]"
