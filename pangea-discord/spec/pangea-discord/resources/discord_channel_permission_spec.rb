# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-discord/resources/discord_channel_permission'

RSpec.describe 'discord_channel_permission' do
  let(:mock_context) { double("context") }
  let(:name) { :test_permission }
  let(:channel_id) { '12345' }
  let(:role_id) { '67890' }
  let(:allowed) { 'read_messages' }
  let(:denied) { 'send_messages' }

  it 'generates a channel permission resource block' do
    expect(mock_context).to receive(:resource).with(:discord_channel_permission, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.channel_id(id); @channel_id = id; end
      def resource_config.role_id(id); @role_id = id; end
      def resource_config.allow(allow); @allow = allow; end
      def resource_config.deny(deny); @deny = deny; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@channel_id)).to eq(channel_id)
      expect(resource_config.instance_variable_get(:@role_id)).to eq(role_id)
      expect(resource_config.instance_variable_get(:@allow)).to eq(allowed)
      expect(resource_config.instance_variable_get(:@deny)).to eq(denied)
    end
    discord_channel_permission(mock_context, name: name, channel_id: channel_id, role_id: role_id, allow: allowed, deny: denied)
  end
end