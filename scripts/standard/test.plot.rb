# @gamefic.script standard/test

meta :test, Query::Text.new do |actor, name|
  sym = name.to_sym
  if test_procs[sym].nil?
    actor.tell "There's no test named '#{name}' in this game."
  else
    run_test sym, actor
  end
end
