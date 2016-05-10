module Gamefic

  # Plots use Source classes to fetch scripts to be executed. The most common
  # type of Source class is Source::File, which searches for scripts in
  # a predefined list of directories on the filesystem, similar to the way
  # that Kernel#require works.
  #
  module Source
    autoload :Base, 'gamefic/source/base'
    autoload :File, 'gamefic/source/file'
    autoload :Text, 'gamefic/source/text'
  end
  
end
