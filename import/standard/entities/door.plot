import 'standard/entities/portal'

class Gamefic::Door < Portal
  attr_reader :key
  def post_initialize
    super
    if @name.nil? and !@direction.nil?
      proper_named = false
      rev = @direction.reverse
      self.name = "the #{@direction.adjective} door"
    end
  end
  def key=(entity)
    @key = entity
    if !@key.nil?
      is :openable, :lockable
    end
    if !find_reverse.nil?
      find_reverse.instance_variable_set(:@key, entity)
    end
  end
  def is(*opts)
    super
    if !self.find_reverse.nil?
      opts.each { |opt|
        find_reverse.option_select opt
      }
    end
  end
end

options Door, :automatic, :not_automatic
options Door, :open, :closed, :locked
options Door, :openable, :not_openable
options Door, :not_lockable, :lockable
options Door, :auto_lockable, :not_auto_lockable
