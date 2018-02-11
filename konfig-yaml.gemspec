
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "konfig_yaml/version"

Gem::Specification.new do |spec|
  spec.name          = "konfig-yaml"
  spec.version       = KonfigYaml::VERSION
  spec.authors       = ["Toshimitsu Takahashi"]
  spec.email         = ["toshi@tilfin.com"]

  spec.summary       = %q{Yaml file SettingsLogic.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/tilfin/konfig-yaml-rb"
  spec.license       = "MIT"

  spec.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + ['.gitignore', 'README.md']
  spec.test_files    = Dir['spec/**/*']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
