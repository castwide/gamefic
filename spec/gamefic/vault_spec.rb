describe Gamefic::Vault do
  it 'adds elements' do
    vault = Gamefic::Vault.new
    object1 = Object.new
    object2 = Object.new
    vault.add object1
    expect(vault.array).to eq([object1])
    vault.add object2
    expect(vault.array).to eq([object1, object2])
  end

  it 'returns frozen arrays' do
    vault = Gamefic::Vault.new
    expect(vault.array).to be_frozen
    vault.add Object.new
    expect(vault.array).to be_frozen
  end

  it 'deletes elements' do
    vault = Gamefic::Vault.new
    object = Object.new
    vault.add object
    vault.delete object
    expect(vault.array).to be_empty
  end

  it 'locks elements' do
    vault = Gamefic::Vault.new
    object1 = Object.new
    object2 = Object.new
    vault.add object1
    vault.lock
    vault.add object2
    expect(vault.deletable?(object1)).to be(false)
    expect(vault.deletable?(object2)).to be(true)
  end

  it 'does not delete locked elements' do
    vault = Gamefic::Vault.new
    object = Object.new
    vault.add object
    vault.lock
    expect(vault.delete(object)).to be(false)
    expect(vault.array).to eq([object])
  end

  it 'deletes unlocked elements in locked vaults' do
    vault = Gamefic::Vault.new
    object1 = Object.new
    object2 = Object.new
    vault.add object1
    vault.lock
    vault.add object2
    expect(vault.delete(object2)).to be(true)
    expect(vault.array).to eq([object1])
  end
end
