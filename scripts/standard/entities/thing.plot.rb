class Thing < Gamefic::Entity
  include ParentRoom

  attr_writer :itemized

  attr_writer :sticky

  attr_writer :portable

  # An optional description to use when itemizing entities in room
  # descriptions. The locale_description will be used instead of adding
  # the entity's name to a list.
  #
  attr_accessor :locale_description

  # A message to be displayed in response to DROP actions when the entity is
  # sticky.
  #
  attr_accessor :sticky_message

  set_default itemized: true
  set_default sticky: false
  set_default portable: false

  # Itemized entities are automatically listed in room descriptions.
  #
  # @return [Boolean]
  def itemized?
    @itemized
  end

  # Sticky entities cannot be dropped with DROP actions
  #
  # @return [Boolean]
  def sticky?
    @sticky
  end

  # Portable entities can be taken with TAKE actions.
  #
  # @return [Boolean]
  def portable?
    @portable
  end

  # @return [Boolean]
  def attached?
    @attached ||= false
  end

  # @param [Boolean]
  def attached= bool
    bool = false if parent.nil?
    @attached = bool
  end

  def parent= p
    attached = false unless p == parent
    super
  end

  # The entity's parent room.
  #
  # @return [Room]
  def room
    p = parent
    while !p.kind_of?(Room) and !p.nil?
      p = p.parent
    end
    p
  end
end
