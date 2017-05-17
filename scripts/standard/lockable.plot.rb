# @gamefic.script standard/lockable

script 'standard/openable'

module Lockable
  include Openable

  attr_accessor :lock_key

  def locked=(bool)
    @locked = bool
    if @locked == true
      self.open = false
    end
  end

  def open=(bool)
    @open = bool
    @locked = false if @open == true
  end

  def locked?
    @locked ||= false
  end

  def has_lock_key?
    !@lock_key.nil?
  end
end

respond :lock, Use.available do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} lock #{the thing}."
end

respond :_toggle_lock, Use.available(Lockable, :has_lock_key?) do |actor, thing|
  verb = thing.locked? ? 'unlock' : 'lock'
  key = nil
  if thing.lock_key.parent == actor
    key = thing.lock_key
  end
  if key.nil?
    actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} have any way to #{verb} #{the thing}."
  else
    actor.tell "#{you.pronoun.Subj} #{you.verb['verb']} #{the thing} with #{the key}."
    thing.locked = !thing.locked?
  end
end

respond :lock, Use.available(Lockable, :has_lock_key?), Use.children do |actor, thing, key|
  if thing.lock_key == key
    actor.perform :_toggle_lock, thing
  else
    actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} unlock #{the thing} with #{the key}."
  end
end

respond :lock, Use.available(Lockable, :has_lock_key?), Use.available do |actor, thing, key|
  actor.perform :take, key if key.parent != actor
  actor.proceed if key.parent == actor
end

respond :unlock, Use.available do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} unlock #{the thing}."
end

respond :unlock, Use.available(Lockable, :has_lock_key?), Use.children do |actor, thing, key|
  if thing.lock_key == key
    actor.perform :_toggle_lock, thing
  else
    actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} unlock #{the thing} with #{the key}."
  end
end

respond :unlock, Use.available(Lockable, :has_lock_key?), Use.available do |actor, thing, key|
  actor.perform :take, key if key.parent != actor
  actor.proceed if key.parent == actor
end

interpret "lock :container with :key", "lock :container :key"
