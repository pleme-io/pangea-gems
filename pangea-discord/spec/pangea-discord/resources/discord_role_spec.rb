# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-discord/resources/discord_role'

RSpec.describe 'discord_role' do
  let(:mock_context) { double("context") }
  let(:name) { :test_role }
  let(:guild_id) { '12345' }
  let(:permissions) { 'read_messages' }

  it 'generates a role resource block' do
    expect(mock_context).to receive(:resource).with(:discord_role, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.name(name); @name = name; end
      def resource_config.guild_id(id); @guild_id = id; end
      def resource_config.permissions(perms); @permissions = perms; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@name)).to eq(self.name.to_s.gsub('_', '-'))
      expect(resource_config.instance_variable_get(:@guild_id)).to eq(guild_id)
      expect(resource_config.instance_variable_get(:@permissions)).to eq(permissions)
    end
    discord_role(mock_context, name: name, guild_id: guild_id, permissions: permissions)
  end
end
