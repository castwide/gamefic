require 'gamefic-sdk/build'

class Gamefic::Sdk::Shell::Command::Build < Gamefic::Shell::Command::Base
  def run
    result parse input
    result = parse input
    Gamefic::Sdk::Build.release result.arguments[1]
  end  
end
