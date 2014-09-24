module Tester
  def test_procs
    @test_procs ||= Hash.new
  end
  def on_test name = 'me', &block
    test_procs[name] = block
  end
  def run_test name, actor
    test_procs[name].call actor
    while actor.queue.length > 0
      update
    end
  end
end
class Plot
  include Tester
end

meta :test, Query::Text.new do |actor, name|
  sym = name.gsub(/ /, '_').to_sym
  if test_procs[sym].nil?
    actor.tell "There's no test named '#{name}' in this game."
  else
    run_test sym, actor
  end
end
