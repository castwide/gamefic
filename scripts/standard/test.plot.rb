# @gamefic.script standard/test

module Tester
  def test_procs
    @test_procs ||= Hash.new
  end

  def on_test name = :me, &block
    test_procs[name] = block
  end

  def run_test name, actor
    queue = []
    test_procs[name].call(actor, queue)
    actor.queue.concat queue
  end
end

extend Tester

meta :test, Gamefic::Query::Text.new do |actor, name|
  sym = name.to_sym
  if test_procs[sym].nil?
    actor.tell "There's no test named '#{name}' in this game."
  else
    run_test sym, actor
  end
end
