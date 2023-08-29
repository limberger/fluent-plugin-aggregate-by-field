lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-aggregate-by-field"
  spec.version = "0.1.0"
  spec.authors = ["jlimberger"]
  spec.email   = ["jlimberger@gmail.com"]

  spec.summary       = %q{This plugin is to concatenate registers by field.}
  spec.description   = %q{This plugin is to concatenate registers by field.}
  spec.homepage      = "https://github.com/limberger/fluent-plugin-aggregate-by-field"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4.19"
  spec.add_development_dependency "rake", "~> 13.0.6"
  spec.add_development_dependency "test-unit", "~> 3.5.7"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
