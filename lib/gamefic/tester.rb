module Gamefic

  module Tester
    def test_procs
      @test_procs ||= Hash.new
    end
    def on_test name = :me, &block
      test_procs[name] = TestQueue.new(&block)
    end
    def run_test name, actor
      queue = test_procs[name].prepare(actor)
      while queue.length > 0
        act = queue.shift
        if act.kind_of?(String)
          actor.queue.push act
        else
          act.call actor
        end
        update
        while (actor.scene.state == 'Paused')
          actor.queue.push ''
          update
        end
      end
    end
    
    class TestQueue
      def queue
        @queue ||= []
      end
      def prepare actor
        queue.clear
        actor.plot.stage actor, queue, &@block
        queue
      end
      def initialize &block
        @block = block
      end
    end
    
  end

end
