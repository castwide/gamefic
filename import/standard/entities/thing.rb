class Thing < Entity
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

options(Thing, :located, :contained, :supported, :attached)
options(Thing, :itemized, :not_itemized)
set_default_for(Thing, :portable)
