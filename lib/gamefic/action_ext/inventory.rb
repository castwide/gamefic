module Gamefic

	Action.new nil, :inventory do |actor|
		if actor.children.length > 0
			actor.tell actor.children.join(', ')
		else
			actor.tell "You aren't carrying anything."
		end
	end
	Syntax.new nil, "i", :inventory

	Action.new nil, :take, Query.new(:siblings, Portable) do |actor, thing|
		thing.parent = actor
		actor.tell "You take #{thing.longname.specify}.", true
	end

	Action.new nil, :take, Query.new(:siblings) do |actor, thing|
		actor.tell "You can't carry #{thing.longname.specify}."
	end

	Action.new nil, :take, Query.new(:string) do |actor, thing|
    containers = actor.children.that_are(Container)
    containers = containers + actor.parent.children.that_are(Container)
    found = false
    containers.each { |container|
      if container.closed? == false
        query = Query.new(:children, Portable)
        result = query.execute(container, thing)
        if result.objects.length == 1
          found = true
          actor.perform "take #{result.objects[0].longname} from #{container.longname}"
          break
        end
      end
    }
    if found == false
      actor.tell "You don't see any \"#{thing}\" here."
    end
	end

	Action.new nil, :drop, Query.new(:children) do |actor, thing|
		thing.parent = actor.parent
		actor.tell "You drop #{thing.longname.specify}.", true
	end

	Syntax.new nil, "get :thing", :take, :thing
	Syntax.new nil, "pick :thing up", :take, :thing
	Syntax.new nil, "pick up :thing", :take, :thing

	Syntax.new nil, "put down :thing", :drop, :thing
	Syntax.new nil, "put :thing down", :drop, :thing

end
