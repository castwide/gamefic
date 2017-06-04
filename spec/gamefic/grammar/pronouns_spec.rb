describe Gamefic::Grammar::Pronouns do
  let(:object) do
    o = Object.new
    o.extend Gamefic::Grammar::Gender
    o.extend Gamefic::Grammar::Person
    o.extend Gamefic::Grammar::WordAdapter
    o
  end

  it "returns 1st person singular" do
    object.person = 1
    expect(object.pronoun.subj).to eq('I')
    expect(object.pronoun.obj).to eq('me')
    expect(object.pronoun.poss).to eq('my')
    expect(object.pronoun.reflex).to eq('myself')
  end

  it "returns 2nd person singular" do
    object.person = 2
    expect(object.pronoun.subj).to eq('you')
    expect(object.pronoun.obj).to eq('you')
    expect(object.pronoun.poss).to eq('your')
    expect(object.pronoun.reflex).to eq('yourself')
  end

  it "returns 3rd person singular neutral" do
    object.person = 3
    expect(object.pronoun.subj).to eq('it')
    expect(object.pronoun.obj).to eq('it')
    expect(object.pronoun.poss).to eq('its')
    expect(object.pronoun.reflex).to eq('itself')
  end

  it "returns 3rd person singular male" do
    object.person = 3
    object.gender = 'male'
    expect(object.pronoun.subj).to eq('he')
    expect(object.pronoun.obj).to eq('him')
    expect(object.pronoun.poss).to eq('his')
    expect(object.pronoun.reflex).to eq('himself')
  end

  it "returns 3rd person singular female" do
    object.person = 3
    object.gender = 'female'
    expect(object.pronoun.subj).to eq('she')
    expect(object.pronoun.obj).to eq('her')
    expect(object.pronoun.poss).to eq('her')
    expect(object.pronoun.reflex).to eq('herself')
  end

  it "returns 1st person plural" do
    object.person = 1
    object.plural = true
    expect(object.pronoun.subj).to eq('we')
    expect(object.pronoun.obj).to eq('us')
    expect(object.pronoun.poss).to eq('our')
    expect(object.pronoun.reflex).to eq('ourselves')
  end

  it "returns 2nd person plural" do
    object.person = 2
    object.plural = true
    expect(object.pronoun.subj).to eq('you')
    expect(object.pronoun.obj).to eq('you')
    expect(object.pronoun.poss).to eq('your')
    expect(object.pronoun.reflex).to eq('yourselves')
  end

  it "returns 3rd person plural" do
    object.person = 3
    object.plural = true
    expect(object.pronoun.subj).to eq('they')
    expect(object.pronoun.obj).to eq('them')
    expect(object.pronoun.poss).to eq('their')
    expect(object.pronoun.reflex).to eq('themselves')
  end
end
