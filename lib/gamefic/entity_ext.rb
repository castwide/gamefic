module Gamefic

  Dir[File.dirname(__FILE__) + '/entity_ext/*.rb'].each do |file|
    require file
  end

end
