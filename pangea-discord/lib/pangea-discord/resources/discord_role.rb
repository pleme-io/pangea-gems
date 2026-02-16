# frozen_string_literal: true

def discord_role(context, name:, guild_id:, permissions:)
  context.resource :discord_role, name do
    guild_id guild_id
    name name.to_s.gsub('_', '-')
    permissions permissions
  end
  { id: "${discord_role.#{name}.id}" }
end
