require 'gamefic'
require 'gamefic-sdk/gfk'
require 'tmpdir'
include Gamefic
include Gamefic::Sdk

describe Gfk do
  before :all do
    @dir = Dir.mktmpdir
  end
  it "initializes a game source directory" do
    shell = Gfk.new
    ARGV.clear
    ARGV.push 'init', "#{@dir}/game", "-q"
    shell.execute
    expect(File.exist?("#{@dir}/game")).to eq(true)
  end
  it "builds a game file" do
    shell = Gfk.new
    ARGV.clear
    ARGV.push 'build', "#{@dir}/game", '-o', "#{@dir}/game.gfic", "-q"
    shell.execute
    expect(File.exist?("#{@dir}/game.gfic")).to eq(true)
  end
  after :all do
    FileUtils.remove_entry_secure @dir
  end
end
