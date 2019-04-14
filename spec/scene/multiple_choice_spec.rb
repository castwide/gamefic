describe Gamefic::Scene::MultipleChoice do
  before :each do
    @plot = Gamefic::Plot.new
    c = Class.new(Gamefic::Entity) { include Gamefic::Active }
    @character = @plot.make c, :name => 'character'
    @after = @plot.pause
    @chooser = @plot.multiple_choice "one", "two", "three", "next" do |actor, data|
      actor[:index] = data.index
      actor[:selection] = data.selection
      if data.selection == 'next'
        actor.cue @after
      else
        actor.cue @plot.default_scene
      end
    end
    @plot.introduce @character
  end

  it "detects a valid numeric answer" do
    ['1', '2', '3', '4'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @character.cue @chooser
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(answer.to_i - 1)
      if answer == '4'
        expect(@character.scene.class).to eq(@after)
      else
        expect(@character.scene.type).to eq('Activity')
      end
    }
  end

  it "detects a valid text answer" do
    ['one', 'two', 'three'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @character.cue @chooser
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:selection]).to eq(answer)
      expect(@character.scene.type).to eq('Activity')
    }
  end

  it "detects an invalid answer and stays in the current scene" do
    @character.cue @chooser
    ['0', 'undecided'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @character.cue @chooser
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(nil)
      expect(@character[:selection]).to eq(nil)
      expect(@character.scene.class).to eq(@chooser)
    }
  end

  it "detects a valid answer and advances to a specified scene" do
    ['4', 'next'].each { |answer|
      @character[:index] = nil
      @character[:selection] = nil
      @character.cue @chooser
      @character.queue.push answer
      @plot.ready
      @plot.update
      expect(@character[:index]).to eq(3)
      expect(@character[:selection]).to eq('next')
      expect(@character.scene.class).to eq(@after)
    }
  end
end
