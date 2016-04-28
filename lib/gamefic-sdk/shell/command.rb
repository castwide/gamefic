require 'slop'

module Gamefic::Sdk::Shell::Command
  autoload :Init, 'gamefic-sdk/shell/command/init'
  autoload :Build, 'gamefic-sdk/shell/command/build'
  autoload :Clean, 'gamefic-sdk/shell/command/clean'
  autoload :Test, 'gamefic-sdk/shell/command/test'
end
