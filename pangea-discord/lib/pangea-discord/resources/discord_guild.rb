# frozen_string_literal: true

def discord_guild(context, name:, region:)
  context.resource :discord_guild, name do
    name name.to_s
    region region
  end
  { id: "${discord_guild.#{name}.id}" }
end
