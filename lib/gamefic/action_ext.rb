# Load a set of commands for moving around rooms, carrying items, looking at
# things, and other basic interactivity.

Dir[File.dirname(__FILE__) + '/action_ext/*.rb'].each do |file|
	require file
end
