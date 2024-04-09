# frozen_string_literal: true

describe Gamefic::Scene::Pause do
  let(:base) { Gamefic::Scene::Pause.new(nil, nil) }

  it 'sets a default prompt' do
    props = base.new_props
    base.start Gamefic::Actor.new, props
    expect(props.prompt).to eq('Press enter to continue...')
  end

  it 'retains existing prompts' do
    props = base.new_props
    props.prompt = 'My custom prompt'
    base.start Gamefic::Actor.new, props
    expect(props.prompt).to eq('My custom prompt')
  end
end
