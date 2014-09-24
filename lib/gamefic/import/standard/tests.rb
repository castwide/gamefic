module Tester
  def test_procs
    @test_procs ||= Hash.new
  end
  def on_test name = 'me', &block
    test_procs[name] = block
  end
  def run_test name, actor
    actor.testing = true
    test_procs[name].call actor
    while actor.queue.length > 0
      actor.plot.update
    end
    actor.testing = false
  end
end
class Plot
  include Tester
end

class Character
  attr_accessor :testing
  alias_method :orig_tester_perform, :perform
  def perform *args
    if testing == true
      tell "[TEST] #{state.prompt} #{args.join(' ')}"
    end
    orig_tester_perform *args
  end
end

meta :test, Query::Text.new do |actor, name|
  sym = name.gsub(/ /, '_').to_sym
  if test_procs[sym].nil?
    actor.tell "There's no test named '#{name}' in this game."
  else
    run_test sym, actor
  end
end
