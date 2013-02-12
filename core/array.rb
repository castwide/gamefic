require "keywords.rb"

x = ['the', 'quick', 'brown', 'fox']
puts x
puts "#{x}"
keywords = Keywords.from(x)
puts keywords.length
