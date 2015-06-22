module Gamefic

  module Stage
    def stage *args, &block
      s = generate_stage
      s.instance_eval(*args, &block)
    end
    private
    def generate_stage
      return @stage if !@stage.nil?
      
      exposed = self.class.exposed_methods.keys
      mounted = self.class.mounted_modules.keys
      
      stage_class = Class.new(Object) do
        class << self
          def class_eval
            raise "no"
          end

          def instance_eval
            raise "no"
          end
        end

        define_method(:initialize) do |instance|
          define_singleton_method(:__instance__) do
            unless caller[0].include?(__FILE__)
              raise "no"
            end
            instance
          end
        end

        exposed.each do |exposed_method|
          define_method(exposed_method) do |*args, &block|
            __instance__.public_send(exposed_method, *args, &block)
          end
        end

        mounted.each { |dsl|
          dsl.public_instance_methods.each { |method|
            define_method(method) do |*args, &block|
              __instance__.public_send(method, *args, &block)
            end
          }
        }
            
        define_method(:class_eval) do
          raise "no"
        end
      end
      @stage = stage_class.new(self)
    end
    module ClassMethods
      def mount *args
        args.each { |a|
          include a
          mounted_modules[a] = nil
        }
      end
      def expose *args
        args.each { |a|
          exposed_methods[a] = nil
        }
      end
      def exposed_methods
        @@exposed_methods ||= from_superclass(:exposed_methods, {}).dup
      end
      def mounted_modules
        @@mounted_modules ||= from_superclass(:mounted_modules, {}).dup
      end
      private
      def from_superclass(m, default = nil)
        superclass.respond_to?(m) ? superclass.send(m) : default
      end
    end
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
  
end
