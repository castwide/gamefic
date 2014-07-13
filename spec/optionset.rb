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
    found1.should eq(set1)
    found2 = mapper.get_option_set_for(BaseUser, :blue)
    found2.should eq(set2)
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
    set.default.should eq(:white)
    set.default = :black
    set.default.should eq(:black)
  end
  it "lets subclasses use different defaults" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    mapper.set_default_for(SubUser, :black)
    mapper.get_default_for(BaseUser, :white).should eq(:white)
    mapper.get_default_for(SubUser, :white).should eq(:black)
  end
end

describe OptionSettings do
  it "receives default settings from its option mapper" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    mapper.options(BaseUser, :red, :blue).default = :blue
    user = BaseUser.new(mapper)
    user.is?(:white).should eq(true)
    user.is?(:blue).should eq(true)
  end
  it "overrides default settings" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    user = BaseUser.new(mapper)
    user.is?(:white).should eq(true)
    user.is :black
    user.is?(:white).should eq(false)
    user.is?(:black).should eq(true)
  end
  it "inherits option settings from its parent class" do
    mapper = OptionMapper.new
    mapper.options(BaseUser, :white, :black)
    user = SubUser.new(mapper)
    user.is?(:white).should eq(true)
  end
end
