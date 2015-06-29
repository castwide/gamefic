module Gamefic::Snapshots
  @@identifiers = {}
  def self.history
    @@history ||= []
  end
  def self.initialize(plot)
    plot.entities.each { |entity|
      identifier = entity.name
      up = entity.parent
      while !up.nil?
        identifier += "|#{up.name}"
        up = up.parent
      end
      @@identifiers[entity] = identifier
    }
  end
  def self.save(plot)
    ss = []
    plot.entities.each { |entity|
      ss.push serialize(entity)
    }
    return ss  
  end
  def self.restore(snapshot, plot)
    if snapshot.kind_of?(String)
      snapshot = JSON.parse(snapshot, :symbolize_names => true)
    end
    snapshot.each { |hash|
      entity = @@identifiers.key(hash[:identifier])
      if !entity.nil?
        unserialize(hash, entity)
        entity.parent = @@identifiers.key(hash[:parent])
      else
        raise "Unable to find entity named #{hash[:name]} with identifier #{hash[:identifier]}"
      end
    }
  end
  def self.serialize(entity)
    hash = {}
    entity.instance_variables.each { |variable|
      symbol = variable[1..-1].to_sym
      if entity.respond_to?("#{symbol}=")
        value = entity.instance_variable_get(variable)
        if !is_blacklisted?(symbol) and is_serializable?(value)
          hash[symbol] = value
        end
      end
      hash[:identifier] = @@identifiers[entity]
      hash[:parent] = @@identifiers[entity.parent]
    }
    hash
  end
  def self.unserialize(hash, entity)
    hash.each { |k, v|
      if !is_blacklisted?(k)
        entity.send("#{k}=", v)
      end
    }
  end
  private
  def self.is_blacklisted?(symbol)
    [:parent, :children, :session, :identifier].include?(symbol)
  end
  def self.is_serializable?(value)
    return (value.kind_of?(String) or value.kind_of?(Numeric) or value.kind_of?(Entity))
  end
end

entity_identities_initialized = false
on_update do
  if !entity_identities_initialized
    Snapshots.initialize(self)
    entity_identities_initialized = true
  end
end

last_snapshot = nil
on_update do
  last_snapshot = Snapshots.save(self)
end
on_player_update do |actor|
  if actor.last_command.last.downcase != "undo"
    Snapshots.history.push last_snapshot
  end
end
