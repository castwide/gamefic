module Gamefic

  # Script classes provide code to be executed in Plots. They are accessed
  # through Source classes, e.g., a Source::Text object is used to find
  # Source::Files. 
  #
  module Script
    autoload :Base, 'gamefic/script/base'
    autoload :File, 'gamefic/script/file'
    autoload :Text, 'gamefic/script/text'
  end

end
