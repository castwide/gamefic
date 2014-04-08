OptionSet.new(Thing, :located, :contained, :supported, :attached).default = :located
OptionSet.new(Thing, :itemized)
OptionSet.set_default_for(Thing, :portable)

class Thing
  def parent=(entity)
    super
    if parent.kind_of?(Supporter)
      is :supported
    elsif parent.kind_of?(Container)
      is :contained
    else
      is :located
    end
  end
end
