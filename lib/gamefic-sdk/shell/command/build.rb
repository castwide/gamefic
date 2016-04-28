require 'gamefic-sdk/build'

class Gamefic::Sdk::Shell::Command::Build < Gamefic::Shell::Command::Base
  def initialize
    options.boolean '-q', '--quiet', 'suppress output', default: false
  end
  
  def run input
    result = parse input
    Gamefic::Sdk::Build.release result.arguments[1], result['--quiet']
  end  
end
