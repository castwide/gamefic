describe "Save/Restore on Web", :type => :feature, :js => true do
  before :each do
    @dir = Dir.mktmpdir
  end
  after :each do
    FileUtils.remove_entry @dir
  end
  it "saves and restores a game" do
    config = Gamefic::Sdk::Config.new('examples/warehouse', { 'release_path' => "#{@dir}/release", 'build_path' => "#{@dir}/build", "libraries" => ["standard"] })
    web = Gamefic::Sdk::Platform::Web.new(config: config)
    web.build
    Capybara.app.root = @dir
    page.visit '/release/web/index.html'
    sleep(0.1) while page.evaluate_script("document.getElementById('gamefic_controls').getAttribute('class').indexOf('working') != -1")
    fill_in 'command', :with => 'take key'
    click_button 'gamefic_submit'
    sleep(0.1)
    fill_in 'command', :with => 'save'
    click_button 'gamefic_submit'
    sleep(0.1)
    fill_in 'command', :with => 'go north'
    click_button 'gamefic_submit'
    sleep(0.1)
    fill_in 'command', :with => 'restore'
    click_button 'gamefic_submit'
    sleep(0.1)
    fill_in 'command', :with => 'inventory'
    click_button 'gamefic_submit'
    sleep(0.1)
    expect(page.has_content? 'You are carrying a key').to eq(true)
  end
end
