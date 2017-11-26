require 'ostruct'

module Gamefic
  module Sdk
    class Binder < OpenStruct
      def initialize config, target_name
        super({config: config, target_name: target_name})
      end

      def relativize src, dst, root
        return dst unless src.start_with?(root) and dst.start_with?(root)
        parts = src[root.length+1..-1].split(File::SEPARATOR).length
        dots = ['..'] * parts
        File.join(*(dots + [dst[root.length..-1]]))
      end

      def relative_target_to_build
        relativize target_path, build_path, config.root_path
      end

      def relative_target_to_root
        relativize target_path, config.root_path, config.root_path
      end

      def target_path
        File.absolute_path File.join(config.target_path, target_name)
      end

      def build_path
        File.absolute_path File.join(config.build_path, target_name)
      end

      def get_binding
        binding()
      end
    end
  end
end
