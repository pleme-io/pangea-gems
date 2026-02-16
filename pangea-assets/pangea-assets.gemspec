# frozen_string_literal: true

lib = File.expand_path(%(lib), __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative %(lib/pangea-assets/version)

Gem::Specification.new do |spec|
  spec.name                   = %(pangea-assets)
  spec.version                = PangeaAssets::VERSION
  spec.authors                = [%(drzthslnt@gmail.com)]
  spec.email                  = [%(drzthslnt@gmail.com)]
  spec.description            = %(assets resources)
  spec.summary                = %(assets resources)
  spec.homepage               = %(https://github.com/drzln/#{spec.name})
  spec.license                = %(MIT)
  spec.require_paths          = [%(lib)]
  spec.required_ruby_version  = %(>=3.3.0)

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  %w[
    rake
    rspec
    rubocop
    ruby-lsp
    rubocop-rake
    rubocop-rspec
    unicode-display_width
    unicode-emoji
  ].each do |dep|
    spec.add_development_dependency dep
  end

  %w[abstract-synthesizer terraform-synthesizer].each do |dep|
    spec.add_dependency dep
  end
  spec.metadata['rubygems_mfa_required'] = 'true'
end
