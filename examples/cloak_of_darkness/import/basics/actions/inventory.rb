respond :inventory do |actor|
  if actor.children.length > 0
    actor.tell actor.children.join(', ')
  else
    actor.tell "You aren't carrying anything."
  end
end
xlate "i", :inventory

respond :take, Query.new(:siblings, Portable) do |actor, thing|
  thing.parent = actor
  actor.tell "You take #{thing.longname.specify}.", true
end

respond :take, Query.new(:siblings) do |actor, thing|
  actor.tell "You can't carry #{thing.longname.specify}."
end

respond :take, Query.new(:string) do |actor, thing|
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

respond :drop, Query.new(:children) do |actor, thing|
  thing.parent = actor.parent
  actor.tell "You drop #{thing.longname.specify}.", true
end

xlate "get :thing", :take, :thing
xlate "pick :thing up", :take, :thing
xlate "pick up :thing", :take, :thing

xlate "put down :thing", :drop, :thing
xlate "put :thing down", :drop, :thing
