# Interview
# A Gamefic demo by Fred Snyder
#
# This game demonstrates interaction with characters. The professor has custom
# responses to questions about his name or the job opening.

import 'standard'

office = make Room, :name => 'the professor\'s office', :description => 'A cozy room with thick carpet, rich mahogany woodwork, and lots of books.'

# Scenery can be used to provide ambience and extra detail. It doesn't usually
# get included in the list of visible entities in the room description, but it
# still provides its description upon direct examination.
carpeting = make Scenery, :name => 'carpet', :synonyms => 'carpeting shag', :description => 'Thick brown shag covers the entire floor.', :parent => office
woodwork = make Scenery, :name => 'mahogany woodwork', :description => 'Finely crafted and varnished to a pleasant sheen.', :parent => office
books = make Scenery, :name => 'books', :synonyms => 'shelves bookshelves', :description => 'Every wall is covered with shelves full of classic literature and literary criticism.', :parent => office

introduction do |actor|
  actor.tell "A friend of yours told you there's a job available in the university's English department. A secretary gave you directions to the man you need to see."
  actor.parent = office
  actor.perform "look"
end

professor = make Character, :name => 'the professor', :synonyms => 'Sam Worthington', :description => 'A gangly older gentleman with thick glasses and a jaunty bowtie.', :parent => office

respond :talk, Query::Reachable.new(professor) do |actor, professor|
  actor.set_state PROMPTED, "What do you want to ask him about? " do |actor, line|
    actor.set_state ACTIVE
    actor.perform "ask professor about #{line}" unless line == ""
  end
end

respond :talk, Query::Reachable.new(professor), Query::Text.new do |actor, professor, subject|
  actor.tell "#{The professor} has nothing to say about #{subject}."
end

respond :talk, Query::Reachable.new(professor), Query::Text.new("name") do |actor, professor, subject|
  actor.tell "\"Professor Sam Worthington. Pleased to meet you.\""
end

respond :talk, Query::Reachable.new(professor), Query::Text.new("job", "opening", "work", "interview") do |actor, professor, subject|
  conclude actor, :asked_about_job
end

conclusion :asked_about_job do |actor|
  actor.tell "#{The professor} smiles. \"Ah, you're here about the job.\" He hands you an application. \"Fill this out and get back to me later.\""
end
