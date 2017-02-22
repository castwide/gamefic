describe Plot::Playbook do
  let(:playbook) { Plot::Playbook.new }

  it "marks actions as meta" do
    action = playbook.meta :verb
    expect(action.meta?).to be true
  end

  it "returns an executable action" do
    num = 0
    action = playbook.respond :increment do
      num += 1
    end
    action.execute
    expect(num).to eq 1
  end

  it "registers an action's verb'" do
    playbook.respond :verb do
    end
    expect(playbook.verbs.length).to eq 1
    expect(playbook.actions_for(:verb).length).to eq 1
  end

  it "freezes commands and syntaxes" do
    playbook.freeze
    expect {
      playbook.respond :verb do
      end
    }.to raise_error(RuntimeError)
  end

  it "requires a syntax's translation to exist'" do
    expect {
      playbook.interpret "foo :thing", "bar :thing"
    }.to raise_error(RuntimeError)
  end

  it "translates to existing verbs" do
    playbook.respond :bar do
    end
    playbook.interpret "foo :thing", "bar :thing"
    expect(playbook.syntaxes.length).to eq 2
  end

  it "generates default syntaxes" do
    playbook.respond :verb do
    end
    expect(playbook.syntaxes.length).to eq 1
    syntax = playbook.syntaxes.first
    expect(syntax.verb).to eq :verb
  end

  it "validates an order" do
    playbook.validate do |order|
      order.cancel unless order.action.verb == :legal
    end
    playbook.respond :legal do |actor|
      actor[:legal] = true
    end
    playbook.respond :illegal do |actor|
      actor[:illegal] = true
    end
    actor = Character.new
    actor.playbook = playbook
    actor.perform 'legal'
    expect(actor[:legal]).to be true
    actor.perform 'illegal'
    expect(actor[:illegal]).not_to be true
  end
end