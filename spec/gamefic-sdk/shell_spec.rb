require 'tmpdir'
require 'gamefic-sdk/shell'

include Gamefic
include Gamefic::Sdk

describe Gamefic::Sdk::Shell::Command::Init do
  before :all do
    @dir = Dir.mktmpdir
  end
  it "initializes a game source directory" do
    ARGV.clear
    ARGV.push 
    command = Gamefic::Sdk::Shell::Command::Init.new
    command.run ['init', "#{@dir}/game", "-q"]
    expect(File.exist?("#{@dir}/game")).to eq(true)
  end
  after :all do
    FileUtils.remove_entry_secure @dir
  end
end
