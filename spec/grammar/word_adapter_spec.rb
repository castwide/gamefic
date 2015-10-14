describe Gamefic::Grammar::WordAdapter do
  it "conjugates be using person and plurality" do
    object = Object.new
    object.extend Gamefic::Grammar::WordAdapter
    object.plural = false
    object.person = 1
    expect(object.verb.be).to eq("am")
    object.person = 2
    expect(object.verb.be).to eq("are")
    object.person = 3
    expect(object.verb.be).to eq("is")
    object.plural = true
    object.person = 1
    expect(object.verb.be).to eq("are")
    object.person = 2
    expect(object.verb.be).to eq("are")
    object.person = 3
    expect(object.verb.be).to eq("are")
  end
  it "conjugates pronouns using person, gender, and plurality" do
    object = Object.new
    object.extend Gamefic::Grammar::WordAdapter
    object.plural = false
    object.person = 1
    expect(object.pronoun.subj).to eq("I")
    object.person = 2
    expect(object.pronoun.subj).to eq("you")
    object.person = 3
    object.gender = "male"
    expect(object.pronoun.subj).to eq("he")
    object.gender = "female"
    expect(object.pronoun.subj).to eq("she")
    object.gender = "other"
    expect(object.pronoun.subj).to eq("they")
    object.gender = "neutral"
    expect(object.pronoun.subj).to eq("it")
    object.plural = true
    object.person = 1
    expect(object.pronoun.subj).to eq("we")
    object.person = 2
    expect(object.pronoun.subj).to eq("you")
    object.person = 3
    expect(object.pronoun.subj).to eq("they")
  end
end
