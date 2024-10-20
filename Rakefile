# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
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
  Opal.append_path File.join(__dir__, 'lib')
  config.default_path = 'spec'
  config.pattern = 'spec/**/*_spec.rb'
  config.requires = ['opal_helper']
end
