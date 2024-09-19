# frozen_string_literal: true

module Gamefic
  class Proxy
    # @return [Symbol]
    attr_reader :type

    # @return [Symbol, String, Integer]
    attr_reader :key

    # @param type [Symbol]
    # @param key [Symbol, String, Integer]
    def initialize type, key
      @type = type
      @key = key
      validate_type
    end

    def fetch narrative
      send(type, narrative) ||
        raise(ArgumentError, "Unable to fetch entity from proxy agent symbol `#{key}`")
    end

    private

    def attr narrative
      Stage.run(narrative, key) { |key| send(key) }
    rescue NoMethodError
      nil
    end

    def ivar narrative
      Stage.run(narrative, key) { |key| instance_variable_get(key) }
    end

    def pick narrative
      Stage.run(narrative, key) { |key| pick!(key) }
    end

    def index narrative
      Stage.run(narrative, key) { |key| entities[key] }
    end

    def validate_type
      return if [:attr, :ivar, :pick, :index].include?(type)

      raise ArgumentError, "Invalid proxy type `#{type}` (must be :attr, :ivar, :pick, or :index)"
    end
  end
end
