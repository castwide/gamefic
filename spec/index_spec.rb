describe Gamefic::Index do
  it 'destroys non-sticky elements' do
    Gamefic::Index.clear
    e1 = Gamefic::Element.new
    Gamefic::Index.stick
    e2 = Gamefic::Element.new
    expect(Gamefic::Index.elements.last).to be(e2)
    e2.destroy
    expect(Gamefic::Index.elements).not_to include(e2)
  end

  it 'does not destroy sticky elements' do
    Gamefic::Index.clear
    element = Gamefic::Element.new
    Gamefic::Index.stick
    expect(Gamefic::Index.elements).to include(element)
    element.destroy
    expect(Gamefic::Index.elements).to include(element)
  end
end
