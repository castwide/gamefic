require 'gamefic-sdk/build'

class Gamefic::Sdk::Shell::Command::Clean < Gamefic::Shell::Command::Base
  def initialize
    #options.boolean '-q', '--quiet', 'suppress output', default: false
  end
  
  def run input
    result = parse input
    Gamefic::Sdk::Build.clean result.arguments[1]
  end  
end
