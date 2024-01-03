# frozen_string_literal: true

describe Gamefic::Scriptable::Scenes do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) do
    klass = Class.new do
      include Gamefic::Scriptable::Scenes

      attr_accessor :rulebook
    end

    klass.new.tap do |obj|
      obj.rulebook = Gamefic::Rulebook.new(stage_func)
    end
  end

  describe '#multiple_choice' do
    it 'creates a multiple choice scene' do
      object.multiple_choice(:scene, %w[one two]) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene.rig).to be(Gamefic::Rig::MultipleChoice)
    end

    it 'sets choices' do
      object.multiple_choice(:scene, %w[one two]) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(:scene, 'MultipleChoice')
      scene.run_start_blocks(nil, props)
      expect(props.options).to eq(%w[one two])
    end
  end

  describe '#yes_or_no' do
    it 'creates a yes-or-no scene' do
      object.yes_or_no(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene.rig).to be(Gamefic::Rig::YesOrNo)
    end

    it 'sets a prompt' do
      object.yes_or_no(:scene, 'What?') { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(:scene, 'YesOrNo')
      scene.run_start_blocks(nil, props)
      expect(props.prompt).to eq('What?')
    end
  end

  describe '#pause' do
    it 'creates a pause scene' do
      object.pause(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene.rig).to be(Gamefic::Rig::Pause)
    end

    it 'sets a prompt' do
      object.pause(:scene, prompt: 'Pause!') { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      props = Gamefic::Props::MultipleChoice.new(:scene, 'Pause')
      scene.run_start_blocks(nil, props)
      expect(props.prompt).to eq('Pause!')
    end
  end

  describe '#conclusion' do
    it 'creates a conclusion' do
      object.conclusion(:scene) { |_actor, _props| nil }
      scene = object.rulebook.scenes[:scene]
      expect(scene.rig).to be(Gamefic::Rig::Conclusion)
    end
  end
end
