# frozen_string_literal: true

require_relative "lib/pangea-discord/version"

Gem::Specification.new do |spec|
  spec.name          = "pangea-discord"
  spec.version       = PangeaDiscord::VERSION
  spec.authors       = ["Pleme.io"]
  spec.email         = ["info@pleme.io"]

  spec.summary       = "Pangea Discord Abstractions"
  spec.description   = "Provides Pangea abstractions for Discord resources."
  spec.homepage      = "https://pleme.io"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads all untracked files that are not in .gitignore.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
