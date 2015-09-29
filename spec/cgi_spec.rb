require "gamefic"
require "gamefic/engine/cgi"
require 'tmpdir'
include Gamefic

describe Cgi::Engine do
  # This is just a stub demonstrating how we might lay the groundwork for a test
  it "does something" do
    plot = Plot.new
    #plot.import 'standard'
    # TODO: I don't think this will work. The shoulds and stuff might not work inside an inline proc.
    Dir.mktmpdir 'gamefic_' do |dir|
      engine = Cgi::Engine.new plot, :session_file => "#{dir}/session.dat", :new_game => true
      expect(2).to eq(2)
    end
  end
end
