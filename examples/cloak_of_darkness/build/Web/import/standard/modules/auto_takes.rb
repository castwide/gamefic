require 'gamefic';module Gamefic;module Gamefic::AutoTakes
  def auto_takes?(entity)
    return true if entity.parent == self
    if AutoTakes.enabled?
      if AutoTakes.taking_message.to_s != ""
        self.tell (AutoTakes.taking_message % {:name => entity.definitely, :Name => entity.definitely.cap_first})
      end
      buff = self.quietly :take, entity
      if entity.parent != self
        self.tell buff
        false
      else
        if AutoTakes.taken_message.to_s != ""
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
    if @enabled.nil?
      @enabled = true
    end
    @enabled
  end
  def self.enabled=(bool)
    @enabled = bool
  end
  def self.taking_message
    @taking_message ||= ""
  end
  def self.taking_message=(text)
    @taking_message = text
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
;end
