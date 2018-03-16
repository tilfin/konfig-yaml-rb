
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "konfig_yaml/version"

Gem::Specification.new do |spec|
  spec.name          = "konfig-yaml"
  spec.version       = KonfigYaml::VERSION
  spec.authors       = ["Toshimitsu Takahashi"]
  spec.email         = ["toshi@tilfin.com"]

  spec.summary       = %q{Loader for YAML configuration with ENVs.}
  spec.description   = %q{The loader of YAML configuration for each execution environments.}
  spec.homepage      = "https://github.com/tilfin/konfig-yaml-rb"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb'] + ['README.md', 'LICENSE']
  spec.test_files    = Dir['spec/**/*'] + Dir['config/**/*']
  spec.require_paths = ["lib"]

  spec.add_dependency "neohash", "~> 0.2"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
