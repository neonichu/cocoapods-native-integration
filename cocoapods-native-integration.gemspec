# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-native-integration.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-native-integration'
  spec.version       = CocoapodsNativeIntegration::VERSION
  spec.authors       = ['Boris Bügling']
  spec.email         = ['boris@buegling.com']
  spec.summary       = 'Natively integrate frameworks instead of via the "Copy Frameworks" script.'
  spec.homepage      = 'https://github.com/neonichu/cocoapods-native-integration'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
