module AutoTakes
  def auto_takes?(entity)
    return true if entity.parent == self
    if AutoTakes.enabled?
      buffer = self.quietly :take, entity
      if entity.parent != self
        self.tell buffer
        false
      else
        if AutoTakes.untaken_message.to_s != ""
          self.tell (AutoTakes.taken_message % {:name => entity.definitely, :Name => entity.definitely.cap_first})
        end
        true
      end
    else
      self.tell (AutoTakes.untaken_message % {:name => entity.definitely, :Name => entity.definitely.cap_first})
      false
    end
  end
  def self.enabled?
    if @default.nil?
      @default = true
    end
    @default
  end
  def self.enabled=(bool)
    @default = bool
  end
  def self.taken_message
    @taken_message ||= ""
  end
  def self.taken_message=(text)
    @taken_message = text
  end
  def self.untaken_message
    @untaken_message ||= "You don't have %{name}."
  end
  def self.untaken_message=(text)
    @untaken_message = text
  end
end
