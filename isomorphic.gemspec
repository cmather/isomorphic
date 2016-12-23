# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'isomorphic/version'

Gem::Specification.new do |spec|
  spec.name          = "isomorphic"
  spec.version       = Isomorphic::VERSION
  spec.authors       = ["Chris Mather"]
  spec.email         = ["chris@eventedmind.com"]

  spec.summary       = %q{Write isomorphic Ruby code.}
  spec.description   = %q{Write isomorphic Ruby code.}
  spec.homepage      = "https://github.com/cmather/isomorphic"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "parser", "~> 2.3"
  spec.add_dependency "ast", "~> 2.3"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
  spec.add_development_dependency "listen", "~> 3.0"
  spec.add_development_dependency "colorize", "~> 0.8"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_development_dependency "unparser", "~> 0.2"
end
