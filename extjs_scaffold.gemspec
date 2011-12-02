# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "extjs_scaffold/version"

Gem::Specification.new do |s|
  s.name        = "extjs_scaffold"
  s.version     = ExtjsScaffold::VERSION
  s.authors     = ["mwinkler"]
  s.email       = ["mhwinkler@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "extjs_scaffold"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec", "~> 2.7.0"
  s.add_development_dependency "rspec-rails", "~> 2.7.0"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "generator_spec"
  s.add_development_dependency 'sass-rails',   '~> 3.1.5'
  s.add_development_dependency 'coffee-rails', '~> 3.1.1'
  s.add_development_dependency 'uglifier', '>= 1.0.3'
  s.add_development_dependency 'turn', '0.8.2'
  s.add_runtime_dependency "rails", "~> 3.1.0"
  s.add_runtime_dependency "kaminari"
  s.add_runtime_dependency "extjs_renderer", "~> 0.1.0"
end
