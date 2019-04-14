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
    expect(object.pronoun.obj).to eq("me")
    expect(object.pronoun.poss).to eq("my")
    object.person = 2
    expect(object.pronoun.subj).to eq("you")
    expect(object.pronoun.obj).to eq("you")
    expect(object.pronoun.poss).to eq("your")
    object.person = 3
    object.gender = "male"
    expect(object.pronoun.subj).to eq("he")
    expect(object.pronoun.obj).to eq("him")
    expect(object.pronoun.poss).to eq("his")
    object.gender = "female"
    expect(object.pronoun.subj).to eq("she")
    expect(object.pronoun.obj).to eq("her")
    expect(object.pronoun.poss).to eq("her")
    object.gender = "other"
    expect(object.pronoun.subj).to eq("they")
    expect(object.pronoun.obj).to eq("them")
    expect(object.pronoun.poss).to eq("their")
    object.gender = "neutral"
    expect(object.pronoun.subj).to eq("it")
    expect(object.pronoun.obj).to eq("it")
    expect(object.pronoun.poss).to eq("its")
    object.plural = true
    object.person = 1
    expect(object.pronoun.subj).to eq("we")
    expect(object.pronoun.obj).to eq("us")
    expect(object.pronoun.poss).to eq("our")
    object.person = 2
    expect(object.pronoun.subj).to eq("you")
    expect(object.pronoun.obj).to eq("you")
    expect(object.pronoun.poss).to eq("your")
    object.person = 3
    expect(object.pronoun.subj).to eq("they")
    expect(object.pronoun.obj).to eq("them")
    expect(object.pronoun.poss).to eq("their")
  end
end
