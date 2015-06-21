module Gamefic

  module Tester
    def test_procs
      @test_procs ||= Hash.new
    end
    def on_test name = :me, &block
      test_procs[name] = block
    end
    def run_test name, actor
      test_procs[name].call actor
      update
      test_queue = actor.queue.clone
      actor.queue.clear
      while test_queue.length > 0
        actor.tell "#{actor.state.prompt} #{test_queue[0]}"
        if actor.scene.state == "Paused"
          actor.queue.unshift ""
        else
          actor.queue.unshift test_queue.shift
        end
        update
      end
    end
  end

end
