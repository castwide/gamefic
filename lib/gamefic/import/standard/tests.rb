module Tester
  def test_procs
    @test_procs ||= Hash.new
  end
  def on_test name = 'me', &block
    test_procs[name] = block
  end
  def run_test name, actor
    actor.state = Testing.new
    test_procs[name].call actor
    actor.state = :active    
    while actor.queue.length > 0
      actor.tell "#{actor.state.prompt} #{actor.queue[0]}"
      actor.state.update actor
      update
    end
  end
end
class Plot
  include Tester
end

class Testing < CharacterState::Base
  def busy?
    true
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
