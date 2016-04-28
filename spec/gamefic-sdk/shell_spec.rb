require 'tmpdir'
require 'gamefic-sdk/shell'

include Gamefic
include Gamefic::Sdk

describe Gamefic::Sdk::Shell::Command do
  before :all do
    @dir = Dir.mktmpdir
  end
  it "initializes a game source directory" do
    command = Gamefic::Sdk::Shell::Command::Init.new
    command.run ['init', "#{@dir}/game", "-q"]
    expect(File.exist?("#{@dir}/game")).to eq(true)
  end
  it "builds a game" do
    command = Gamefic::Sdk::Shell::Command::Build.new
    command.run ['build', "#{@dir}/game", "-q"]
    expect(File.exist?("#{@dir}/game/release/gfic/game.gfic")).to eq(true)
    expect(File.exist?("#{@dir}/game/release/web")).to eq(true)
  end
  after :all do
    FileUtils.remove_entry_secure @dir
  end
end
