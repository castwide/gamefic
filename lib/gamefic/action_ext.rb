module Gamefic

	Dir[File.dirname(__FILE__) + '/action_ext/*.rb'].each do |file|
		require file
	end

end
