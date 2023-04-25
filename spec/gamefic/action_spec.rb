# frozen_string_literal: true

describe Gamefic::Action do
  let(:actor) { Object.new.tap { |obj| obj.extend Gamefic::Active } }

  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'executes actions' do
    executed = false
    response = Gamefic::Response.new(:verb, stage_func, []) { |_| executed = true }
    action = Gamefic::Action.new(nil, [], response)
    action.execute
    expect(executed).to be(true)
  end

  it 'marks actions executed' do
    response = Gamefic::Response.new(:verb, stage_func, []) { |_| nil }
    action = Gamefic::Action.new(nil, [], response)
    expect(action).not_to be_executed
    action.execute
    expect(action).to be_executed
  end

  it 'does not execute cancelled actions' do
    response = Gamefic::Response.new(:verb, stage_func, []) { |_| nil }
    action = Gamefic::Action.new(nil, [], response)
    action.cancel
    action.execute
    expect(action).not_to be_executed
  end

  it 'runs before_action hooks' do
    playbook = Gamefic::Playbook.new
    executed = false
    playbook.before_action { |_action| executed = true }
    actor.playbooks.add playbook
    response = Gamefic::Response.new(:verb, stage_func, []) { |_| nil }
    action = Gamefic::Action.new(actor, [], response, true)
    action.execute
    expect(executed).to be(true)
  end

  it 'runs after_action hooks' do
    playbook = Gamefic::Playbook.new
    executed = false
    playbook.after_action { |_action| executed = true }
    actor.playbooks.add playbook
    response = Gamefic::Response.new(:verb, stage_func, []) { |_| nil }
    action = Gamefic::Action.new(actor, [], response, true)
    action.execute
    expect(executed).to be(true)
  end
end
