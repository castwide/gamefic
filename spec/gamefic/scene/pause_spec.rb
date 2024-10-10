# frozen_string_literal: true

describe Gamefic::Scene::Pause do
  let(:actor) { Gamefic::Actor.new }

  let(:base) { Gamefic::Scene::Pause.new(actor) }

  it 'sets a default prompt' do
    base.start
    expect(base.props.prompt).to eq('Press enter to continue...')
  end

  it 'retains existing prompts' do
    base.props.prompt = 'My custom prompt'
    base.start
    expect(base.props.prompt).to eq('My custom prompt')
  end
end
