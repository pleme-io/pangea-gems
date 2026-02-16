# frozen_string_literal: true

def security_group_rule(context, name, security_group_id, type, from_port, to_port, protocol,
                        cidr_blocks = [], source_security_group_id = nil)
  context.resource :aws_security_group_rule, name do
    security_group_id security_group_id
    type type
    from_port from_port
    to_port to_port
    protocol protocol
    cidr_blocks cidr_blocks unless cidr_blocks.empty?
    source_security_group_id source_security_group_id unless source_security_group_id.nil?
  end
end
