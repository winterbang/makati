
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "makati/version"

Gem::Specification.new do |spec|
  spec.name          = "makati"
  spec.version       = Makati::VERSION
  spec.authors       = ["winter"]
  spec.email         = ["zwtao90@gmail.com"]

  spec.summary       = %q{抽象控制器增删改查的功能}
  spec.description   = %q{省去了在控制器中重复写增删改查功能}
  spec.homepage      = "https://winterbang.github.io/makati"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_dependency "reform"
  spec.add_dependency "reform-rails"
  spec.add_dependency "kaminari"
  spec.add_dependency "ransack"

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
