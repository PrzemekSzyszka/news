# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "news"
  spec.version       = "0.0.2"
  spec.authors       = ["Przemysław Szyszka"]
  spec.email         = ["przemeklo@o2.pl"]
  spec.summary       = ["Summary"]
  spec.description   = ["Description"]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack-test", "~> 0.6.2"
  spec.add_development_dependency "sinatra", "~> 1.4.5"
  spec.add_development_dependency "dotenv-rails", "~> 1.0.2"
  spec.add_development_dependency "activerecord", "~> 4.2.0"
  spec.add_development_dependency "sqlite3", "~> 1.3.1"
  spec.add_development_dependency "database_cleaner", "~> 1.3.0"
end
