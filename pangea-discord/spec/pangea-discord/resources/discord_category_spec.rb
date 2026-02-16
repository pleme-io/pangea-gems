# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-discord/resources/discord_category'

RSpec.describe 'discord_category' do
  let(:mock_context) { double("context") }
  let(:name) { :test_category }
  let(:guild_id) { '12345' }

  it 'generates a category resource block' do
    expect(mock_context).to receive(:resource).with(:discord_category, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.name(name); @name = name; end
      def resource_config.guild_id(id); @guild_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@name)).to eq(self.name.to_s)
      expect(resource_config.instance_variable_get(:@guild_id)).to eq(guild_id)
    end
    discord_category(mock_context, name: name, guild_id: guild_id)
  end
end
