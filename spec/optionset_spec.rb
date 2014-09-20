require 'gamefic'
include Gamefic

class OptionMapper
  include OptionMap
end

class BaseUser
  include OptionSettings
  def initialize(mapper)
    @option_mapper = mapper
  end
end

class SubUser < BaseUser

end

describe OptionMap do
  it "finds an option set's default from a member option" do
    mapper = OptionMapper.new
    set1 = mapper.options(BaseUser, :white, :black)
    set2 = mapper.options(BaseUser, :red, :blue)
    found1 = mapper.get_option_set_for(BaseUser, :white)
    expect(found1).to eq(set1)
    found2 = mapper.get_option_set_for(BaseUser, :blue)
    expect(found2).to eq(set2)
  end
  it "raises an exception for less that two options" do
    mapper = OptionMapper.new
    expect {
      mapper.options(BaseUser)
    }.to raise_error(Exception)
    expect {
      mapper.options(BaseUser, :only)
    }.to raise_error(Exception)
  end
  it "raises an exception for invalid default options" do
    mapper = OptionMapper.new
    set = mapper.options(BaseUser, :white, :black)
    expect {
      set.default = :red
    }.to raise_error(Exception)
  end
  it "accepts and identifies default options" do
    mapper = OptionMapper.new
    set = mapper.options(BaseUser, :white, :black)
    expect(set.default).to eq(:white)
    set.default = :black
    expect(set.default).to eq(:black)
  end
  it "lets subclasses use different defaults" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    mapper.set_default_for(SubUser, :black)
    expect(mapper.get_default_for(BaseUser, :white)).to eq(:white)
    expect(mapper.get_default_for(SubUser, :white)).to eq(:black)
  end
end

describe OptionSettings do
  it "receives default settings from its option mapper" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    mapper.options(BaseUser, :red, :blue).default = :blue
    user = BaseUser.new(mapper)
    expect(user.is?(:white)).to eq(true)
    expect(user.is?(:blue)).to eq(true)
  end
  it "overrides default settings" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    user = BaseUser.new(mapper)
    expect(user.is?(:white)).to eq(true)
    user.is :black
    expect(user.is?(:white)).to eq(false)
    expect(user.is?(:black)).to eq(true)
  end
  it "inherits option settings from its parent class" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    user = SubUser.new(mapper)
    expect(user.is?(:white)).to eq(true)
  end
  it "returns true for undefined :not_* options and false for others" do
    mapper = OptionMapper.new
    user = BaseUser.new(mapper)
    expect(user.is?(:foo)).to eq(false)
    expect(user.is?(:not_foo)).to eq(true)
  end
end
