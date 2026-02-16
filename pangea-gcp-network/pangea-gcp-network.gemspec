# frozen_string_literal: true

require_relative "lib/pangea-gcp-network/version"

Gem::Specification.new do |spec|
  spec.name          = "pangea-gcp-network"
  spec.version       = PangeaGcpNetwork::VERSION
  spec.authors       = ["Pleme.io"]
  spec.email         = ["info@pleme.io"]

  spec.summary       = "Pangea GCP Network Abstractions"
  spec.description   = "Provides Pangea abstractions for GCP Network resources."
  spec.homepage      = "https://pleme.io"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads all untracked files that are not in .gitignore.
  spec.files = Dir.glob("lib/**/*") + Dir.glob("*.md") + ["pangea-gcp-network.gemspec"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a dependency for a gem that this gem depends on.
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "abstract-synthesizer", "~> 0.0"
end
