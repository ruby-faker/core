# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

Dir["tasks/**/*.rake"].each { |rake| load rake }

require "bundler"
require "standard/rake"

Bundler::GemHelper.install_tasks

desc "Start a console session with Faker loaded"
task :console do
  require "irb"
  require "irb/completion"
  require "faker-core" # You know what to do.

  ARGV.clear
  IRB.start
end

task default: %w[test standard]
