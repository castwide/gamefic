class Gamefic::Shell::Subcommand::Base
  # Execute the command
  #
  def run
    raise "Unimplemented command"
  end
  
  # Get the documentation for this command.
  # The gamefic executable will provide this text in response to
  # "gamefic help [command]"
  #
  # @return [String]
  def help
    "Help is not available for this command."
  end
end
