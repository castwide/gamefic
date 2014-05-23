respond :drop_on, Query::Children.new(), Query::Reachable.new(Supporter) do |actor, thing, supporter|
  thing.parent = supporter
  thing.is :supported
  actor.tell "You put #{the thing} on #{the supporter}."
end

xlate "put :thing on :supporter", :drop_on, :thing, :supporter
xlate "put :thing down on :supporter", :drop_on, :thing, :supporter
xlate "set :thing on :supporter", :drop_on, :thing, :supporter
xlate "set :thing down on :supporter", :drop_on, :thing, :supporter
xlate "drop :thing on :supporter", :drop_on, :thing, :supporter
xlate "place :thing on :supporter", :drop_on, :thing, :supporter
