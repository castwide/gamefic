require 'ostruct'

module Gamefic
  module Sdk
    class Binder < OpenStruct
      def initialize config, target_name
        super({config: config, target_name: target_name})
      end

      # Get the relative path from src to dst given the common root.
      # If src and dst do not share a common root, return the absolute
      # path to dst.
      #
      # @return [String]
      def relativize src, dst, root
        return dst unless src.start_with?(root) and dst.start_with?(root)
        parts = src[root.length+1..-1].split(File::SEPARATOR).length
        dots = ['..'] * parts
        if dst == root
          File.join(*dots)
        else
          File.join(*(dots + [dst[root.length..-1]]))
        end
      end

      # The relative path from the target directory to the build directory.
      #
      # Example:
      # - current_target_path is /project/targets/my_target
      # - current_build_path is /project/builds/my_target
      # - relative_target_to_build is ../../builds/my_target
      #
      # @return [String]
      def relative_target_to_build
        relativize current_target_path, current_build_path, config.root_path
      end

      # The relative path from the target directory to the project directory.
      #
      # Example:
      # - current_target_path is /project/targets/my_target
      # - current_root_path is /project
      # - relative_target_to_root is ../..
      #
      # @return [String]
      def relative_target_to_root
        relativize current_target_path, config.root_path, config.root_path
      end

      # @return [String]
      def current_root_path
        config.root_path
      end

      # @return [String]
      def current_target_path
        File.absolute_path File.join(config.target_path, target_name)
      end

      # @return [String]
      def current_build_path
        File.absolute_path File.join(config.build_path, target_name)
      end

      def get_binding
        binding()
      end
    end
  end
end
