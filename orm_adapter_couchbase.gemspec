# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orm_adapter_couchbase/version'

Gem::Specification.new do |spec|
  spec.name          = "orm_adapter_couchbase"
  spec.version       = OrmAdapterCouchbase::VERSION
  spec.authors       = ["Philipp Fehre"]
  spec.email         = ["philipp.fehre@googlemail.com"]
  spec.description   = %q{Adds Couchbase support to ORM Adapter}
  spec.summary       = %q{Use Couchbase Model to add support for Couchbase ORM Adapter}
  spec.homepage      = "https://github.com/sideshowcoder/orm_adapter_couchbase"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "couchbase-model", "~> 0.5.3"
  spec.add_dependency "orm_adapter", "~> 0.5.0"

  spec.add_development_dependency "rspec", ">= 2.4.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
