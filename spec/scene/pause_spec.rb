describe Scene::Pause do
  it "changes the character's state after a response" do
    plot = Plot.new
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    character[:has_paused] = false
    plot.pause :pause do |actor|
      actor[:has_paused] = true
    end
    plot.introduce character
    character.cue :pause
    expect(character.scene).to eq(:pause)
    character.queue.push ""
    plot.ready
    plot.update
    expect(character.scene).to eq(:active)
    expect(character[:has_paused]).to eq(true)
  end
end
