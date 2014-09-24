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
    actor.testing = false
  end
end
class Plot
  include Tester
end

class Character
  @@performance_depth = 0
  attr_accessor :testing
  alias_method :orig_tester_perform, :perform
  def perform *args
    @@performance_depth += 1
    if testing == true
      tell "[TEST] #{state.prompt} #{args.join(' ')}"
    end
    orig_tester_perform *args
    if testing == true and @@performance_depth == 1
      plot.update
    end
    @@performance_depth -= 1
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
