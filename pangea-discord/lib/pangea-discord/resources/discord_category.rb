# frozen_string_literal: true

def discord_category(context, name:, guild_id:)
  context.resource :discord_category, name do
    guild_id guild_id
    name name.to_s
  end
  { id: "${discord_category.#{name}.id}" }
end
