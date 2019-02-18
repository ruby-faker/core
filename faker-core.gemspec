# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "faker/version"

Gem::Specification.new do |s|
  s.name        = "faker-core"
  s.version     = Faker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Benjamin Curtis"]
  s.email       = ["benjamin.curtis@gmail.com"]
  s.homepage    = "https://github.com/ruby-faker/core"
  s.summary     = "Generate fake data"
  s.description = "Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc."
  s.license     = "MIT"

  s.add_runtime_dependency("i18n", ">= 1")

  s.add_development_dependency("minitest")
  s.add_development_dependency("rake")
  s.add_development_dependency("standard")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("test-unit")

  s.required_ruby_version = ">= 2.3"

  s.files         = Dir["lib/**/*"] # + %w[CHANGELOG.md README.md LICENSE]
  s.require_paths = ["lib"]

  s.metadata["changelog_uri"] = "https://github.com/ruby-faker/core/blob/master/CHANGELOG.md"
  s.metadata["source_code_uri"] = "https://github.com/ruby-faker/core"
  s.metadata["bug_tracker_uri"] = "https://github.com/ruby-faker/core/issues"
end
