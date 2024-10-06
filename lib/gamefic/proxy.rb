# frozen_string_literal: true

module Gamefic
  # @todo Turn this into a module after the old proxies are completely deprecated
  #
  class Proxy
    require 'gamefic/proxy/base'
    require 'gamefic/proxy/config'
    require 'gamefic/proxy/pick'
    require 'gamefic/proxy/plot_pick'

    TYPES = %i[attr ivar pick pick! plot_pick plot_pick! config].freeze

    # @return [Symbol]
    attr_reader :type

    # @return [Symbol, Array<Symbol>, String, Integer]
    attr_reader :key

    # @param type [Symbol]
    # @param key [Symbol, String, Array]
    def initialize type, key
      Gamefic.logger.debug "Using deprecated #{type} proxy"
      @type = type
      validate_type
      @key = type == :config ? [key].compact : key
    end

    def fetch narrative
      send(type, narrative) ||
        raise(ArgumentError, "Unable to fetch entity from proxy agent symbol `#{key}`")
    end

    def [](key)
      raise ArgumentError, 'Invalid []' unless type == :config

      @key.push key
      self
    end

    private

    def attr narrative
      Stage.run(narrative, [key].flatten) { |keys| keys.inject(self) { |obj, key| obj.send key } }
    rescue NoMethodError
      nil
    end

    def ivar narrative
      narrative.instance_variable_get key
    end

    def pick narrative
      narrative.pick *key
    end

    def pick! narrative
      narrative.pick! *key
    end

    def plot_pick narrative
      narrative.plot.pick *key
    end

    def plot_pick! narrative
      narrative.plot.pick! *key
    end

    def config narrative
      key.inject(narrative.config) { |hash, key| hash[key] }
    end

    def validate_type
      return if TYPES.include?(type)

      raise ArgumentError, "Invalid proxy type `#{type}` (must be #{TYPES.join_or})"
    end
  end
end
