module Gamefic

  module Tester
    def test_procs
      @test_procs ||= Hash.new
    end
    def on_test name = :me, &block
      test_procs[name] = block
    end
    def run_test name, actor
      queue = []
      stage actor, queue, &test_procs[name]
      actor.queue.push *queue
      actor[:test_queue_length] = queue.length
      actor[:test_queue_scene] = actor.scene
    end
  end

end
