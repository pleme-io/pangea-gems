# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-discord/resources/discord_guild'

RSpec.describe 'discord_guild' do
  let(:mock_context) { double("context") }
  let(:name) { :test_guild }
  let(:region) { 'us-west' }

  it 'generates a guild resource block' do
    expect(mock_context).to receive(:resource).with(:discord_guild, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.name(name); @name = name; end
      def resource_config.region(region); @region = region; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@name)).to eq(self.name.to_s)
      expect(resource_config.instance_variable_get(:@region)).to eq(region)
    end
    discord_guild(mock_context, name: name, region: region)
  end
end