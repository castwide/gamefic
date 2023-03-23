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
      if object.is_a?(Class)
        exclusions[:classes].any? { |k, v| object <= k && v.include?(ivar) }
      else
        exclusions[:objects].any? { |k, v| object.is_a?(k) && v.include?(ivar) }
      end
    end
  end
end
