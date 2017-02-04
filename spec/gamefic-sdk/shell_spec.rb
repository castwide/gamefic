require 'tmpdir'
require 'gamefic-sdk/shell'

include Gamefic
include Gamefic::Sdk

describe Gamefic::Sdk::Shell::Init do
  before :all do
    @dir = Dir.mktmpdir
  end

  it "initializes a game source directory" do
    Gamefic::Sdk::Shell::Init.new(directory: "#{@dir}/game", quiet: true).run
    expect(File.exist?("#{@dir}/game")).to eq(true)
  end

  after :all do
    FileUtils.remove_entry_secure @dir
  end
end
