# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-discord/resources/discord_channel'

RSpec.describe 'discord_channel' do
  let(:mock_context) { double("context") }
  let(:name) { :test_channel }
  let(:guild_id) { '12345' }
  let(:type) { 'text' }
  let(:parent_id) { '67890' }

  it 'generates a channel resource block' do
    expect(mock_context).to receive(:resource).with(:discord_channel, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.name(name); @name = name; end
      def resource_config.guild_id(id); @guild_id = id; end
      def resource_config.type(type); @type = type; end
      def resource_config.parent_id(id); @parent_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@name)).to eq(self.name.to_s.gsub('_', '-'))
      expect(resource_config.instance_variable_get(:@guild_id)).to eq(guild_id)
      expect(resource_config.instance_variable_get(:@type)).to eq(type)
      expect(resource_config.instance_variable_get(:@parent_id)).to eq(parent_id)
    end
    discord_channel(mock_context, name: name, guild_id: guild_id, type: type, parent_id: parent_id)
  end
end
