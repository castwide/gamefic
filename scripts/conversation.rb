action :talk, query(:siblings, Character) do |actor, person|
	actor.tell "#{person} has nothing to say."
end
action :talk, query(:siblings, Character), query(:string) do |actor, person, subject|
	actor.tell "#{person} has nothing to say about #{subject}."
end
instruct "talk to [person]", :talk, "[person]"
instruct "talk with [person]", :talk, "[person]"
instruct "chat with [person]", :talk, "[person]"
instruct "talk to [person] about [subject]", :talk, "[person] [subject]"
instruct "talk with [person] about [subject]", :talk, "[person] [subject]"
instruct "chat with [person] about [subject]", :talk, "[person] [subject]"

action :show_to, query(:siblings, Character), query(:family) do |actor, person, thing|
	actor.tell "#{person} has nothing to say about #{thing.longname}."
end
