# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'pangea-discord entry point' do
  # Runs a fresh ruby subprocess so this spec cannot pass by side-effect
  # of sibling specs that require_relative individual resource files.
  it 'exposes all resource helpers after a single top-level require' do
    lib = File.expand_path('../lib', __dir__)
    helpers = %w[
      discord_guild
      discord_category
      discord_channel
      discord_role
      discord_channel_permission
    ]
    check = helpers.map { |h| "exit 1 unless Object.private_method_defined?(:#{h})" }.join('; ')
    ok = system(RbConfig.ruby, '-I', lib, '-r', 'pangea-discord', '-e', "#{check}; exit 0")
    expect(ok).to eq(true),
      "`require \"pangea-discord\"` in a fresh interpreter did not expose all helpers: #{helpers.join(', ')}"
  end
end
