describe "Save/Restore on Web", :type => :feature, :js => true do
  before :each do
    @dir = Dir.mktmpdir
  end
  after :each do
    FileUtils.remove_entry @dir
  end
  it "saves and restores a game" do
    config = { 'target_dir' => "#{@dir}/release", 'build_dir' => "#{@dir}/build" }
    web = Gamefic::Sdk::Platform::Web.new("examples/warehouse", config)
    web.build
    url = "file://" + (@dir.start_with?('/') ? '' : '/') + @dir + '/release/index.html'
    visit url
    sleep(0.1) while page.evaluate_script("$('#gamefic_controls').hasClass('working')")
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
