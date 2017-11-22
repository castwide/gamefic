require 'gamefic-library'

class Gamefic::Library::Standard < Gamefic::Library::Base
  def path
    Gamefic::Sdk::GLOBAL_SCRIPT_PATH
  end
end
