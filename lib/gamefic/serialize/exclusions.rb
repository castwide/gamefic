# frozen_string_literal: true

module Gamefic
  module Serialize
    def self.exclusions
      @exclusions ||= {
        classes: {
          Scene::Base => [:@start_block, :@finish_block]
        },
        objects: {
          Active => [:@playbooks],
          Plot => [:@subplots, :@playbook, :@introduction],
          Subplot => [:@plot, :@playbook, :@introduction]  
        }
      }
    end

    # True if the object should not serialize the instance variable.
    #
    def self.exclude?(object, ivar)
      klass = object.is_a?(Class) ? object : object.class
      EXCLUSIONS.any? { |k, v| klass <= k && v.include?(ivar) }
    end
  end
end
