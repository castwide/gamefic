# frozen_string_literal: true

describe Gamefic::Scriptable::Scenes do
  let(:object) do
    Class.new do
      extend Gamefic::Scriptable
    end
  end

  describe '#multiple_choice' do
    it 'creates a multiple choice scene' do
      object.multiple_choice(:scene) { |scene| scene.on_start { |_, props| props.concat(%w[one two]) } }
      scene = object.named_scenes[:scene].new(nil)
      expect(scene).to be_a(Gamefic::Scene::MultipleChoice)
    end

    it 'sets choices' do
      object.multiple_choice(:scene) { |scene| scene.on_start { |_, props| props.options.push('one', 'two') } }
      actor = Gamefic::Actor.new
      scene = object.named_scenes[:scene].new(actor)
      scene.start
      expect(scene.props.options).to eq(%w[one two])
    end
  end

  describe '#yes_or_no' do
    it 'creates a yes-or-no scene' do
      object.yes_or_no(:scene) {}
      scene = object.named_scenes[:scene].new(nil)
      expect(scene).to be_a(Gamefic::Scene::YesOrNo)
    end

    it 'sets a prompt' do
      object.yes_or_no(:scene) { |scene| scene.on_start { |_, props| props.prompt = 'What?' } }
      actor = Gamefic::Actor.new
      scene = object.named_scenes[:scene].new(actor)
      scene.start
      expect(scene.props.prompt).to eq('What?')
    end
  end

  describe '#pause' do
    it 'creates a pause scene' do
      object.pause(:scene) { |_actor, _props| nil }
      scene = object.named_scenes[:scene].new(nil)
      expect(scene).to be_a(Gamefic::Scene::Pause)
    end

    it 'sets a prompt' do
      object.pause(:scene) { |_actor, props| props.prompt = 'Pause!' }
      actor = Gamefic::Actor.new
      scene = object.named_scenes[:scene].new(actor)
      scene.start
      expect(scene.props.prompt).to eq('Pause!')
    end
  end

  describe '#conclusion' do
    it 'creates a conclusion' do
      object.conclusion(:scene) { |_actor, _props| nil }
      scene = object.named_scenes[:scene].new(nil)
      expect(scene).to be_a(Gamefic::Scene::Conclusion)
    end
  end

  describe '#scene' do
    it 'accesses scenes' do
      object.block(Gamefic::Scene::Base, :scene)
      expect(object.named_scenes[:scene] <= Gamefic::Scene::Base).to be
    end
  end
end
