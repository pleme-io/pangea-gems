# frozen_string_literal: true

def discord_channel_permission(context, name:, channel_id:, role_id:, allow:, deny:)
  context.resource :discord_channel_permission, name do
    channel_id channel_id
    role_id role_id
    allow allow
    deny deny
  end
  { id: "${discord_channel_permission.#{name}.id}" }
end
