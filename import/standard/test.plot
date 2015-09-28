meta :test, Query::Text.new do |actor, name|
  sym = name.to_sym
  if test_procs[sym].nil?
    actor.tell "There's no test named '#{name}' in this game."
  else
    run_test sym, actor
    cue actor, :test
  end
end

class TestSceneManager < SceneManager
  def state
    @state ||= "Testing"
  end
end

scene_managers[:test] = TestSceneManager.new do |config|
  config.start do |actor, data|
    #while actor[:test_queue_scene].state == 'Paused' or actor[:test_queue_scene].state == 'Passive'
    #  #puts "Paused"
    #  #data.input = ''
    #  actor[:test_queue_scene].start actor
    #  cue_key = actor[:test_queue_scene].data.next_cue
    #  cue_key = :active if cue_key.nil?
    #  puts "Next cue: #{cue_key}"
    #  actor[:test_queue_scene] = scene_managers[cue_key].prepare cue_key
    #end
    test_scene = actor.scene
    actor.scene = actor[:test_queue_scene]
    actor.scene.start actor
    while actor.scene.state == 'Passive'
      actor.scene.finish actor, nil
      actor.scene.start actor
    end
    actor[:test_queue_scene] = actor.scene
    actor.scene = test_scene
    if actor[:test_queue_scene].state == 'Paused'
      data.input = ''
    else
      data.input = actor[:test_queue].shift
    end
    if data.input.nil?
      actor[:testing] = false
      actor.tell "(#{actor[:test_queue_length]} commands tested.)"
      actor.scene = actor[:test_queue_scene]
      #actor.scene.start actor
    else
      actor.queue.push data.input
    end
  end
  config.finish do |actor, data|
    actor.tell "[TESTING] #{actor[:test_queue_scene].data.prompt} #{data.input}"
    test_scene = actor.scene
    actor.scene = actor[:test_queue_scene]
    actor.scene.finish actor, data.input
    #while actor.scene.state == 'Passive'
    #  actor.scene.finish actor, nil
    #  actor.scene.start actor
    #end
    #if !data.next_cue.nil?
    #  cue actor, data.next_cue
    #end
    actor[:test_queue_scene] = actor.scene
    actor.scene = test_scene
    #if actor[:test_queue_scene].state == 'Paused'
    #  actor.plot.update
    #end
  end
end
