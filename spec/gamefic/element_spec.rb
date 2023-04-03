describe Gamefic::Element do
  it 'sets default attributes from superclasses' do
    klass1 = Class.new(Gamefic::Element)
    klass1.class_exec { attr_accessor :klass }
    klass2 = Class.new(klass1)
    klass1.set_default klass: 'klass1'
    klass2.set_default klass: 'klass2'
    expect(klass1.new.klass).to eq('klass1')
    expect(klass2.new.klass).to eq('klass2')
  end
end
