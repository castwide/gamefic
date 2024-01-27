describe Gamefic::Active::Epic do
  let(:klass) do
    Class.new(Gamefic::Narrative) do
      script { pause :pause }
    end
  end

  it 'selects scenes from multiple narratives' do
    expect(Gamefic::Logging.logger).to receive(:warn).with(/found 2 scenes/i)
    plot1 = klass.new
    plot2 = klass.new
    epic = Gamefic::Active::Epic.new
    epic.add plot1
    epic.add plot2
    scene = epic.select_scene(:pause)
    expect(scene).to be(plot2.rulebook.scenes[:pause])
  end
end
