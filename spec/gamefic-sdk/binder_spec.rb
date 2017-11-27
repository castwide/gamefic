describe Gamefic::Sdk::Binder do
  it "finds relative paths" do
    config = Gamefic::Sdk::Config.new('root', 'target_path' => './targets', 'build_path' => './builds/final')
    binder = Gamefic::Sdk::Binder.new(config, 'app')
    expect(binder.relative_target_to_build).to eq(File.join('..', '..', 'builds', 'final', 'app'))
    expect(binder.relative_target_to_root).to eq(File.join('..', '..'))
  end
end
