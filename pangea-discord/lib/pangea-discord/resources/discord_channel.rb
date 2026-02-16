# frozen_string_literal: true

def discord_channel(context, name:, guild_id:, type:, parent_id: nil)
  context.resource :discord_channel, name do
    guild_id guild_id
    name name.to_s.gsub('_', '-')
    type type
    parent_id parent_id unless parent_id.nil?
  end
  { id: "${discord_channel.#{name}.id}" }
end
