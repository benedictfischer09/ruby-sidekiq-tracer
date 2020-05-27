# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/tracer/version"

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-instrumentation"
  spec.version       = Sidekiq::Tracer::VERSION
  spec.authors       = ["iaintshine", "Doximity"]
  spec.email         = ["ops@doximity.com"]
  spec.license       = "Apache-2.0"

  spec.summary       = %q{OpenTracing instrumentation for Sidekiq.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/doximity/ruby-sidekiq-tracer"

  spec.required_ruby_version = ">= 2.2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features|vendor|tasks|tmp)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'opentracing', '>= 0.3.1'
  spec.add_dependency 'sidekiq'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "dox-style"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "sdoc"
  spec.add_development_dependency "test-tracer", "~> 1.0", ">= 1.2.1"
  spec.add_development_dependency "tracing-matchers", "~> 1.0", ">= 1.3.0"
end
