# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "olsen/version"

Gem::Specification.new do |s|
  s.name        = "olsen"
  s.version     = Olsen::VERSION
  s.authors     = ["Fred McDavid"]
  s.email       = ["fred@landmetrics.com"]
  s.homepage    = "http://www.landmetrics.com/Olsen"
  s.summary     = %q{A gem that provides olsen, a reporting tool}
  s.description = %q{Olsen is a reporting tool intended to be used with Sadie.}

  s.rubyforge_project = "olsen"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_runtime_dependency "sadie"
  s.extra_rdoc_files = ['README', 'CHANGELOG', 'TODO']
end
