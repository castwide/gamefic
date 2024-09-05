# frozen_string_literal: true

describe Gamefic::Scriptable::Scenes do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) do
    klass = Class.new do
      include Gamefic::Scriptable::Scenes

      attr_accessor :rulebook
    end

    klass.new.tap do |obj|
      obj.rulebook = Gamefic::Rulebook.new
    end
  end

  describe '#preface' do
    it 'creates an activity scene with a custom start block' do
      object.preface(:scene) { |_, props| props.output[:executed] = true }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::Default.new(scene)
      scene.run_start_blocks(nil, props)
      expect(props.output[:executed]).to be(true)
    end
  end

  describe '#multiple_choice' do
    it 'creates a multiple choice scene' do
      object.multiple_choice(:scene, %w[one two]) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene).to be_a(Gamefic::Scene::MultipleChoice)
    end

    it 'sets choices' do
      object.multiple_choice(:scene, %w[one two]) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(scene)
      scene.run_start_blocks(nil, props)
      expect(props.options).to eq(%w[one two])
    end
  end

  describe '#yes_or_no' do
    it 'creates a yes-or-no scene' do
      object.yes_or_no(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene).to be_a(Gamefic::Scene::YesOrNo)
    end

    it 'sets a prompt' do
      object.yes_or_no(:scene, 'What?') { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(scene)
      scene.run_start_blocks(nil, props)
      expect(props.prompt).to eq('What?')
    end
  end

  describe '#pause' do
    it 'creates a pause scene' do
      object.pause(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene).to be_a(Gamefic::Scene::Pause)
    end

    it 'sets a prompt' do
      object.pause(:scene, prompt: 'Pause!') { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(scene)
      scene.run_start_blocks(nil, props)
      expect(props.prompt).to eq('Pause!')
    end
  end

  describe '#conclusion' do
    it 'creates a conclusion' do
      object.conclusion(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene).to be_a(Gamefic::Scene::Conclusion)
    end
  end
end
