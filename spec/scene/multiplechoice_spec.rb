describe MultipleChoiceScene do
  before :each do
    @plot = Plot.new
    @character = @plot.make Character, :name => 'character'
    @plot.multiple_choice :choose, "one", "two", "three", "next" do |actor, data|
      actor[:index] = data.index
      actor[:selection] = data.selection
      if data.selection == 'next'
        data.next_cue = :next
      end
    end
    @plot.pause :next
    @plot.introduce @character
  end
  it "detects a valid numeric answer and advances to the next scene" do
    ['1', '2', '3'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @plot.cue @character, :choose
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(answer.to_i - 1)
      expect(@character.scene.key).to eq(:active)
    }
  end
  it "detects a valid text answer and advances to the next scene" do
    ['one', 'two', 'three'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @plot.cue @character, :choose
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:selection]).to eq(answer)
      expect(@character.scene.key).to eq(:active)
    }
  end
  it "detects an invalid answer and stays in the current scene" do
    @plot.cue @character, :choose
    ['0', 'undecided'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @plot.cue @character, :choose
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(nil)
      expect(@character[:selection]).to eq(nil)
      expect(@character.scene.key).to eq(:choose)
    }
  end
  it "detects a valid answer and advances to a custom scene" do
    ['4', 'next'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @plot.cue @character, :choose
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(3)
      expect(@character[:selection]).to eq('next')
      expect(@character.scene.key).to eq(:next)
    }
  end
end
