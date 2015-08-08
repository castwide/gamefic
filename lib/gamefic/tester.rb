module Gamefic

  module Tester
    def test_procs
      @test_procs ||= Hash.new
    end
    def on_test name = :me, &block
      test_procs[name] = TestQueue.new(&block)
    end
    def run_test name, actor
      #test_procs[name].call actor
      #update
      #test_queue = actor.queue.clone
      #actor.queue.clear
      #while test_queue.length > 0
      #  actor.tell "#{actor.scene.data.prompt} #{test_queue[0]}"
      #  if actor.scene.state == "Paused"
      #    actor.queue.unshift ""
      #  else
      #    actor.queue.unshift test_queue.shift
      #  end
      #  update
      #end
      queue = test_procs[name].queue
      actor.tell "Gonna try! #{queue.join("\n")}"
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
      include Stage
      expose :queue
      def queue
        @queue ||= []
      end
      def initialize &block
        stage &block
        puts queue.join("\n")
      end
    end
    
  end

end
