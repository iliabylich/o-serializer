
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "o/serializer/version"

Gem::Specification.new do |spec|
  spec.name          = "o-serializer"
  spec.version       = O::Serializer::VERSION
  spec.authors       = ["Ilya Bylich"]
  spec.email         = ["ibylich@gmail.com"]

  spec.summary       = %q{o-serializer}
  spec.description   = %q{o-serializer}
  spec.homepage      = "https://github.com/iliabylich/o-serializer"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
