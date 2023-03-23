describe Gamefic::Plot::Darkroom do
  it 'verifies program metadata' do
    plot = Gamefic::Plot.new
    snapshot = plot.save
    snapshot['program'] = { 'valid' => false }
    expect { plot.restore snapshot }.to raise_error(LoadError)
  end
end
