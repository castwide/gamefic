module Gamefic::Sdk

  class Platform::Web < Platform::Base
    include Gamefic::Sdk::Platform::OpalBuilder

    def build
      FileUtils.mkdir_p build_dir
      FileUtils.cp_r(File.join(target_dir, '.'), build_dir)
      File.write File.join(build_dir, 'core', 'opal.js'), build_opal_str(true)
      copy_media
    end

    def make_target
      write_files_to_target File.join(Gamefic::Sdk::PLATFORMS_PATH, 'web')
    end
  end
end
