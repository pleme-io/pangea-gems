# frozen_string_literal: true

lib = File.expand_path(%(lib), __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative %(lib/pangea-os/version)

Gem::Specification.new do |spec|
  spec.name                   = %(pangea-os)
  spec.version                = PangeaOS::VERSION
  spec.authors                = [%(drzthslnt@gmail.com)]
  spec.email                  = [%(drzthslnt@gmail.com)]
  spec.description            = %(os resources)
  spec.summary                = %(os resources)
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
    debug
    rubocop
    ruby-lsp
    rubocop-rake
    rubocop-rspec
    debug_inspector
  ].each do |dep|
    spec.add_development_dependency dep
  end

  %w[
    abstract-synthesizer
    terraform-synthesizer
    aws-sdk-ec2
    aws-sdk-s3
    aws-sdk-iam
    ox
  ].each do |dep|
    spec.add_dependency dep
  end
  spec.metadata['rubygems_mfa_required'] = 'true'
end
