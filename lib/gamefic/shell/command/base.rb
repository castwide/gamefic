require 'gamefic/shell'
require 'slop'

class Gamefic::Shell::Command::Base
  # Execute the command
  #
  def run input
    raise "Unimplemented command"
  end
  
  # Get the options for the command
  #
  # @return [Slop::Options]
  def options
    @options ||= Slop::Options.new
  end
  
  # Get the help documentation for this command.
  #
  # @return [String]
  def help
    optons.to_s
  end
  
  protected
  
  # @return [Slope::Result]
  def parse input
    parser.parse input
  end
  
  private

  # @return [Slop::Parser]  
  def parser
    @parser ||= Slop::Parser.new(options)
  end
end
