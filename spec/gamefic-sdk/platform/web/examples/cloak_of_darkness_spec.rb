require 'gamefic-sdk'
require 'tmpdir'

describe "Cloak of Darkness (Web)", type: :feature, js: true do
  before :each do
    @dir = Dir.mktmpdir
  end

  after :each do
    FileUtils.remove_entry @dir
  end

  it "concludes web game with test me" do
    config = Gamefic::Sdk::Config.new('examples/cloak_of_darkness', { 'release_path' => "#{@dir}/release", 'build_path' => "#{@dir}/build" })
    web = Gamefic::Sdk::Platform::Web.new(config: config)
    web.build
    url = "file://" + (@dir.start_with?('/') ? '' : '/') + @dir + '/release/web/index.html'
    visit url
    sleep(0.1) while page.evaluate_script("$('#gamefic_controls').hasClass('working')")
    fill_in 'command', with: 'test me'
    click_button 'gamefic_submit'
    sleep(0.1) while page.evaluate_script("$('#gamefic_controls').hasClass('working')")
    expect(page.evaluate_script("$('#gamefic_console').hasClass('concluded')")).to eq(true)
  end
end
