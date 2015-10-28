require 'gamefic-sdk'
require 'tmpdir'

describe "Warehouse (Web)", :type => :feature, :js => true do
  before :each do
    @dir = Dir.mktmpdir
  end
  after :each do
    FileUtils.remove_entry @dir
  end
  it "concludes web game with test me" do
    plot = Gamefic::Sdk::Debug::Plot.new(Source.new('./import', Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.load "examples/warehouse/main.plot"
    config = { 'target_dir' => "#{@dir}/release", 'build_dir' => "#{@dir}/build" }
    web = Gamefic::Sdk::Platform::Web.new(plot, config)
    web.build
    visit("#{@dir}/release/index.html")
    sleep(0.1) while page.evaluate_script("$('#controls').hasClass('working')")
    fill_in 'command', :with => 'test me'
    click_button 'commandenter'
    sleep(0.1) while page.evaluate_script("$('#controls').hasClass('working')")
    expect(page).to have_content 'Play Again?'
  end
end
