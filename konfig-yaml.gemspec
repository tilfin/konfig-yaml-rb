
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "konfig_yaml/version"

Gem::Specification.new do |spec|
  spec.name          = "konfig-yaml"
  spec.version       = KonfigYaml::VERSION
  spec.authors       = ["Toshimitsu Takahashi"]
  spec.email         = ["toshi@tilfin.com"]

  spec.summary       = %q{Loader for yaml base configuration with ENVs.}
  spec.description   = %q{The loader of yaml base configuration for each run enviroments.}
  spec.homepage      = "https://github.com/tilfin/konfig-yaml-rb"
  spec.license       = "MIT"

  spec.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + ['.gitignore', 'LICENSE']
  spec.test_files    = Dir['spec/**/*']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
