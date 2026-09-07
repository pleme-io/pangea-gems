# frozen_string_literal: true

require 'spec_helper'

# Minimal context stub matching the surface the five discord_* helpers
# rely on: `.resource(:type, name) { block }` where the block declares
# attributes as method calls (e.g. `name "foo"`, `guild_id "bar"`).
class RecordingContext
  Recorded = Struct.new(:type, :name, :attrs)

  attr_reader :resources

  def initialize
    @resources = []
  end

  def resource(type, name, &block)
    recorder = AttrRecorder.new
    recorder.instance_exec(&block)
    @resources << Recorded.new(type, name, recorder.attrs)
  end

  def find(type, name)
    @resources.find { |r| r.type == type && r.name == name }
  end

  class AttrRecorder < BasicObject
    attr_reader :attrs

    def initialize
      @attrs = {}
    end

    def method_missing(key, value = nil)
      @attrs[key] = value
    end

    def respond_to_missing?(*) = true
  end
end

RSpec.describe 'pangea-discord composed template' do
  let(:context) { RecordingContext.new }

  before do
    guild = discord_guild(context, name: :pleme_dev, region: 'brazil')
    category = discord_category(context, name: :general_cat, guild_id: guild[:id])
    channel = discord_channel(
      context,
      name: :general,
      guild_id: guild[:id],
      type: 'text',
      parent_id: category[:id]
    )
    role = discord_role(
      context,
      name: :admin,
      guild_id: guild[:id],
      permissions: 8
    )
    discord_channel_permission(
      context,
      name: :general_admin,
      channel_id: channel[:id],
      role_id: role[:id],
      allow: 0,
      deny: 0
    )
  end

  it 'declares all five resource types' do
    types = context.resources.map(&:type)
    expect(types).to contain_exactly(
      :discord_guild,
      :discord_category,
      :discord_channel,
      :discord_role,
      :discord_channel_permission
    )
  end

  it 'wires child resources to the guild via Terraform interpolation' do
    guild_ref = '${discord_guild.pleme_dev.id}'
    expect(context.find(:discord_category, :general_cat).attrs[:guild_id]).to eq(guild_ref)
    expect(context.find(:discord_channel, :general).attrs[:guild_id]).to eq(guild_ref)
    expect(context.find(:discord_role, :admin).attrs[:guild_id]).to eq(guild_ref)
  end

  it 'nests the channel under its category via parent_id interpolation' do
    expect(context.find(:discord_channel, :general).attrs[:parent_id])
      .to eq('${discord_category.general_cat.id}')
  end

  it 'binds the channel_permission to both the channel and the role' do
    perm = context.find(:discord_channel_permission, :general_admin).attrs
    expect(perm[:channel_id]).to eq('${discord_channel.general.id}')
    expect(perm[:role_id]).to eq('${discord_role.admin.id}')
  end

  it 'normalizes underscores to dashes in channel and role display names' do
    expect(context.find(:discord_channel, :general).attrs[:name]).to eq('general')
    expect(context.find(:discord_role, :admin).attrs[:name]).to eq('admin')
  end
end
