# frozen_string_literal: true

def security_group(context, name, vpc_id, description, tags = {})
  context.resource :aws_security_group, name do
    vpc_id vpc_id
    description description
    tags tags
  end
end