# frozen_string_literal: true

describe String do
  it "capitalizes the first letter without changing the rest" do
    expect("name".cap_first).to eq("Name")
    expect("beginning of sentence".cap_first).to eq("Beginning of sentence")
    expect("ALL CAPS".cap_first).to eq("ALL CAPS")
  end

  it "splits words on any whitespace" do
    expect("one two".keywords).to eq(["one", "two"])
    expect(" one  two   ".keywords).to eq(["one", "two"])
    expect("one, two\nthree".keywords).to eq(["one,", "two", "three"])
  end
end
