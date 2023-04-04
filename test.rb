require 'bundler/setup'
require 'gamefic'

plot = Gamefic::Plot.new
query = plot.available
puts query.inspect
