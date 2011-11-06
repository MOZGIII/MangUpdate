# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "MangUpdate/version"

Gem::Specification.new do |s|
  s.name        = "MangUpdate"
  s.version     = MangUpdate::VERSION
  s.authors     = ["MOZGIII"]
  s.email       = ["mike-n@narod.ru"]
  s.homepage    = ""
  s.summary     = %q{Use Mupfiles to update your MaNGOS server database.}
  s.description = %q{This is a small gem that will help you with updating your MaNGOS server. It uses Mupfile to keep all database update logic simple.}

  s.rubyforge_project = "MangUpdate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "activesupport"
end
