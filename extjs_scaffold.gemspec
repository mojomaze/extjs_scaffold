# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "extjs_scaffold/version"

Gem::Specification.new do |s|
  s.name        = "extjs_scaffold"
  s.version     = ExtjsScaffold::VERSION
  s.authors     = ["mwinkler"]
  s.email       = ["mhwinkler@gmail.com"]
  s.homepage    = "https://github.com/mojomaze/extjs_scaffold"
  s.summary     = "Scaffold Generator for Rails 3.2 and Extjs 4.1"
  s.description = "Scaffold Generator for Rails 3.2 and Sencha Extjs 4.1"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec", "~> 2.7.0"
  s.add_development_dependency "rspec-rails", "~> 2.7.0"
  s.add_development_dependency "generator_spec"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "aruba", "< 0.4.7"
  s.add_runtime_dependency "rails", "~> 3.2.0"
  s.add_runtime_dependency "extjs_renderer"
end
