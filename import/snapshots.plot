module Gamefic::Snapshots
  def self.make_identifier entity
      identifier = "ENTITY<" + entity.name
      up = entity.parent
      while !up.nil?
        identifier += "|#{up.name}"
        up = up.parent
      end
      identifier += ">"
      identifier
  end
  def self.is_identifier? value
    value.kind_of?(String) and value.start_with?("ENTITY<") and value.end_with?(">")
  end
  @@identifiers = {}
  def self.history
    @@history ||= []
  end
  def self.initialize(plot)
    plot.entities.each { |entity|
      @@identifiers[entity] = make_identifier(entity)
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
    lookup = @@identifiers.invert
    snapshot.each { |hash|
      entity = lookup[hash[:identifier]]
      if !entity.nil?
        unserialize(hash, entity)
        #entity.parent = lookup[hash[:parent]]
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
          if value.kind_of?(Entity)
            hash[symbol] = @@identifiers[value]
          else
            hash[symbol] = value
          end
        end
      end
      hash[:identifier] = @@identifiers[entity]
      hash[:parent] = @@identifiers[entity.parent]
    }
    hash
  end
  def self.unserialize(hash, entity)
    lookup = @@identifiers.invert
    hash.each { |k, v|
      if !is_blacklisted?(k)
        if is_identifier?(v)
          entity.send("#{k}=", lookup[v])
        else
          entity.send("#{k}=", v)
        end
      end
    }
  end
  private
  def self.is_blacklisted?(symbol)
    [:children, :session, :identifier].include?(symbol)
  end
  def self.is_serializable?(value)
    return (value.kind_of?(String) or value.kind_of?(Numeric) or value.kind_of?(Entity) or value.kind_of?(Symbol))
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
  if !actor.last_order.nil? and actor.last_order.action.verb != :undo
    Snapshots.history.push last_snapshot
  end
end
