require 'gamefic'
require 'gamefic/shell'
require 'tmpdir'
include Gamefic

describe Shell do
  before :all do
    @dir = Dir.mktmpdir
  end
  it "initializes a game source directory" do
    shell = Shell.new
    ARGV.clear
    ARGV.push 'init', "#{@dir}/game"
    shell.execute
    File.exist?("#{@dir}/game").should eq(true)
  end
  it "builds a game file" do
    shell = Shell.new
    ARGV.clear
    ARGV.push 'build', "#{@dir}/game", '-o', "#{@dir}/game.gfic"
    shell.execute
    File.exist?("#{@dir}/game.gfic").should eq(true)
  end
  after :all do
    FileUtils.remove_entry_secure @dir
  end
end
