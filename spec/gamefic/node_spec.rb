describe Gamefic::Node do
  it "adds a node to a parent" do
    x = Object.new
    x.extend Gamefic::Node
    y = Object.new
    y.extend Gamefic::Node
    y.parent = x
    expect(y.parent).to eq(x)
    expect(x.children.include? y).to eq(true)
  end

  it "removes a node from a parent" do
    x = Object.new
    x.extend Gamefic::Node
    y = Object.new
    y.extend Gamefic::Node
    y.parent = x
    y.parent = nil
    expect(y.parent).not_to eq(x)
    expect(x.children.include?(y)).to eq(false)
  end

  it "flattens a tree of children" do
    x = Object.new
    x.extend Gamefic::Node
    y = Object.new
    y.extend Gamefic::Node
    z = Object.new
    z.extend Gamefic::Node
    y.parent = x
    z.parent = y
    flat = x.flatten
    expect(flat).to eq([y, z])
  end

  it "does not permit a node to be its own parent" do
    x = Object.new
    x.extend Gamefic::Node
    expect {
      x.parent = x
    }.to raise_error Gamefic::NodeError
  end

  it "does not permit circular references" do
    x = Object.new
    x.extend Gamefic::Node
    y = Object.new
    y.extend Gamefic::Node
    x.parent = y
    expect {
      y.parent = x
    }.to raise_error(Gamefic::NodeError)
    z = Object.new
    z.extend Gamefic::Node
    x.parent = y
    y.parent = z
    expect {
      z.parent = x
    }.to raise_error Gamefic::NodeError
  end
end
