Gem::Specification.new do |s|
  s.name = %q{TBD}
  s.authors = "Scott, Shai"
  s.version = "0.0.02"
  s.date = %q{2019-01-04}
  s.summary = %q{Oracle SQL connectors}
  s.files = [
    "lib/tbd.rb"
  ]
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency "dbi"
  s.add_runtime_dependency "httparty"
end