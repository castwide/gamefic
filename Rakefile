# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rspec/core/rake_task'
require 'opal/rspec/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
  # t.rspec_opts << ' more options'
  #t.rcov = true
end
task :default => :spec

Opal::RSpec::RakeTask.new(:opal) do |_, config|
  Opal.append_path File.expand_path('../lib', __FILE__)
  config.pattern = 'spec/**/*_spec.rb'
  config.requires = ['spec_helper']
end
