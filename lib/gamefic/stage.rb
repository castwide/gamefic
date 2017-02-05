module Gamefic

  module Stage
    def stage *args, &block
      s = generate_stage
      if block.nil?
        s.module_eval(*args)
      else
        s.module_exec(*args, &block)
      end
    end

    private

    def generate_stage
      return @stage unless @stage.nil?
      
      exposed = self.class.exposed_methods.keys
      mounted = self.class.mounted_modules.keys
      instance = self
      
      @stage = Module.new do
        define_singleton_method(:__instance__) do
          unless caller.length == 0 or caller[0].include?(__FILE__)
            raise NoMethodError.new("Method __instance__ is not available from the stage.")
          end
          instance
        end
        exposed.each do |exposed_method|
          define_singleton_method(exposed_method) do |*args, &block|
            __instance__.public_send(exposed_method, *args, &block)
          end
        end
        mounted.each { |dsl|
          dsl.public_instance_methods.each { |method|
            define_singleton_method(method) do |*args, &block|
              #puts "Calling a mounted method"
              result = __instance__.public_send(method, *args, &block)
              #puts "Done"
              result
            end
          }
        }
      end
      
      return @stage 
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
